class PublishController < FormController
  before_action :assign_form_objects

  def index
    @published_dev = PublishServicePresenter.new(publishes_dev, service)
    @published_production = PublishServicePresenter.new(publishes_production, service)
    declarations
  end

  def create
    return unless can_publish_to_live || publish_service_params[:deployment_environment] == 'dev'

    @publish_service_creation = PublishServiceCreation.new(publish_service_params)
    ms_list_updated = prepare_ms_list_integration(publish_service_params[:deployment_environment]) == false

    @publish_service_creation.errors.add(:ms_list, message: 'An error occured creating the new list required to publish your form. Please contact us.') unless ms_list_updated
    if @publish_service_creation.save
      if previous_service_slug.present?
        UnpublishServiceJob.perform_later(
          publish_service_id: published_service.id,
          service_slug: previous_service_slug.decrypt_value
        )

        all_previous_service_slugs.destroy_all
      end

      PublishServiceJob.perform_later(
        publish_service_id: @publish_service_creation.publish_service_id
      )
      redirect_to publish_index_path(service.service_id)
    else
      update_form_objects
      render :index
    end
  end

  def publish_for_review
    declarations
    declarations.checked(publish_for_review_params['declarations_checkboxes'].reject(&:blank?))

    ms_list_updated = prepare_ms_list_integration('production')

    @publish_service_creation = PublishServiceCreation.new(publish_for_review_params.except('authenticity_token', 'declarations_checkboxes'))

    @publish_service_creation.errors.add(:ms_list, message: 'An error occured creating the new list required to publish your form. Please contact us.') unless ms_list_updated

    unless @declarations.valid?
      update_form_objects
      render :index, status: :unprocessable_entity and return
    end

    if @publish_service_creation.valid?
      if @publish_service_creation.save
        # not sure if it should ever be present
        if previous_service_slug.present?
          UnpublishServiceJob.perform_later(
            publish_service_id: published_service.id,
            service_slug: previous_service_slug.decrypt_value
          )

          all_previous_service_slugs.destroy_all
        end

        unless current_user.email == 'fb-acceptance-tests@digital.justice.gov.uk'
          PublishServiceJob.perform_later(
            publish_service_id: @publish_service_creation.publish_service_id
          )
          NotificationService.notify(review_message, webhook: ENV['SLACK_REVIEW_WEBHOOK'])
        end

        approval = ServiceConfiguration.find_or_initialize_by(
          service_id: service.service_id,
          deployment_environment: 'production',
          name: 'AWAITING_APPROVAL'
        )
        if approval.new_record?
          approval.value = '1'
          approval.save
        end

        update_form_objects
        redirect_to "#{publish_index_path(service.service_id)}#publish-to-live" and return
      end
      update_form_objects
      redirect_to "#{publish_index_path(service.service_id)}#publish-to-live" and return
    end
  end

  def can_publish_to_live
    if ServiceConfiguration.find_by(
      service_id: service.service_id,
      name: 'REVOKED'
    ).present?
      false
    elsif ServiceConfiguration.find_by(
      service_id: service.service_id,
      name: 'APPROVED_TO_GO_LIVE'
    ).present?
      true
    elsif ServiceConfiguration.find_by(
      service_id: service.service_id,
      name: 'AWAITING_APPROVAL'
    ).present?
      false
    else
      PublishService.find_by(
        service_id: service.service_id,
        deployment_environment: 'production'
      ).present?
    end
  end
  helper_method :can_publish_to_live

  def show_confirmation?
    ServiceConfiguration.find_by(
      service_id: service.service_id,
      name: 'AWAITING_APPROVAL'
    ).present?
  end
  helper_method :show_confirmation?

  def declaration_errors
    if @errors.present?
      if @errors.any?
        @errors
      end
    else
      []
    end
  end
  helper_method :declaration_errors

  def text_for_environment(env)
    env == 'dev' ? 'Test' : 'Live'
  end
  helper_method :text_for_environment

  def form_url(env)
    "https://#{hostname(env)}"
  end
  helper_method :form_url

  def prepare_ms_list_integration(env)
    ms_site_id_config = ServiceConfiguration.find_by(
      service_id: service.service_id,
      deployment_environment: env,
      name: 'MS_SITE_ID'
    )
    send_to_graph = SubmissionSetting.find_by(
      service_id: service.service_id,
      deployment_environment: env
    ).try(:send_to_graph_api?)

    if ms_site_id_config.nil? || send_to_graph == false
      return true
    end

    latest = if env == 'dev'
               publishes_dev&.last
             else
               publishes_production&.last
             end

    if latest.published?
      if latest.version_id != service.version_id
        create_ms_list_and_drive(ms_site_id_config.decrypt_value, service, env)
      else
        true
      end
    else
      true
    end
  end

  def create_ms_list_and_drive(site_id, service, env)
    adapter = MicrosoftGraphAdapter.new(site_id:, service:, env:)

    response = adapter.post_list_columns

    list_created = false
    drive_created = false

    if response.status == 201
      list_id = JSON.parse(response.body)['id']

      service_config = create_or_update_the_service_configuration('MS_LIST_ID', env)
      service_config.value = list_id
      list_created = service_config.save!
    end

    drive_name = CGI.escape("#{service.service_name}-#{env}-#{service.version_id}-attachments")

    response = adapter.create_drive(drive_name)

    if response.status == 201
      created_id = JSON.parse(response.body)['id']

      service_config = create_or_update_the_service_configuration('MS_DRIVE_ID', env)
      service_config.value = created_id
      drive_created = service_config.save!
    end

    list_created && drive_created == true
  end

  private

  def create_or_update_the_service_configuration(config, env)
    find_or_initialize_setting(config, env)
  end

  def find_or_initialize_setting(config, env)
    ServiceConfiguration.find_or_initialize_by(
      service_id: service.service_id,
      deployment_environment: env,
      name: config
    )
  end

  def hostname(env)
    root_url = Rails.application.config
      .platform_environments[platform_environment][:url_root]

    if env == 'production'
      [service_slug, '.', root_url].join
    else
      [service_slug, '.', 'dev', '.', root_url].join
    end
  end

  def platform_environment
    ENV['PLATFORM_ENV']
  end

  def service_autocomplete_items
    @service_autocomplete_items ||= MetadataApiClient::Items.all(service_id: service.service_id)
  end

  def publish_service_params
    params.require(:publish_service_creation).permit(
      :require_authentication,
      :username,
      :password,
      :deployment_environment
    ).merge(
      service_id: service.service_id,
      user_id: current_user.id,
      version_id: service.version_id
    )
  end

  def publish_for_review_params
    params.require(:publish_for_review_declarations).permit(
      :authenticity_token,
      declarations_checkboxes: []
    ).merge(
      require_authentication: '1',
      username: ENV['PUBLISH_FOR_REVIEW_USERNAME'],
      password: ENV['PUBLISH_FOR_REVIEW_PASSWORD'],
      deployment_environment: 'production',
      service_id: service.service_id,
      user_id: current_user.id,
      version_id: service.version_id
    )
  end

  def review_message
    if platform_environment == 'test'
      "#{service.service_name} has been published for review *in the test environment* using the review credentials.\n#{hostname('production')}"
    else
      "#{service.service_name} has been published for review using the review credentials.\n#{hostname('production')}"
    end
  end

  def assign_form_objects
    @publish_page_presenter_dev = PublishingPagePresenter.new(
      service:,
      deployment_environment: 'dev',
      service_autocomplete_items:,
      grid:
    )
    @publish_page_presenter_production = PublishingPagePresenter.new(
      service:,
      deployment_environment: 'production',
      service_autocomplete_items:,
      grid:
    )
  end

  def publishes_dev
    @publishes_dev ||= PublishService.where(
      service_id: service.service_id
    ).dev
  end

  def publishes_production
    @publishes_production ||= PublishService.where(
      service_id: service.service_id
    ).production
  end

  def update_form_objects
    @published_dev = PublishServicePresenter.new(publishes_dev, service)
    @published_production = PublishServicePresenter.new(publishes_production, service)
    if @publish_service_creation.deployment_environment == 'dev'
      @publish_page_presenter_dev.publish_creation = @publish_service_creation
    else
      @publish_page_presenter_production.publish_creation = @publish_service_creation
    end
  end

  def declarations
    @declarations ||= PublishForReviewDeclarations.new
  end

  def published_service
    PublishService.where(
      service_id: service.service_id,
      deployment_environment: 'dev'
    ).completed.desc.first
  end

  def previous_service_slug
    ServiceConfiguration.find_by(
      service_id: service.service_id,
      name: 'PREVIOUS_SERVICE_SLUG'
    )
  end

  def all_previous_service_slugs
    ServiceConfiguration.where(
      service_id: service.service_id,
      name: 'PREVIOUS_SERVICE_SLUG'
    )
  end
end
