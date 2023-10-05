class PublishController < FormController
  before_action :assign_form_objects

  def index
    @published_dev = PublishServicePresenter.new(publishes_dev, service)
    @published_production = PublishServicePresenter.new(publishes_production, service)
  end

  def create
    @publish_service_creation = PublishServiceCreation.new(publish_service_params)

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
    declarations = publish_for_review_params['declarations_checkboxes'].compact
    @publish_service_creation = PublishServiceCreation.new(publish_for_review_params.except("authenticity_token", "declarations_checkboxes"))
    if declarations.length != 7
      update_form_objects
      @errors = [I18n.t('publish.declarations.error')]
      render :index, status: :unprocessable_entity and return
    end

    if @publish_service_creation.valid?
      update_form_objects
      @show_confirmation = true
      render :index
    end
  end

  def can_publish_to_live
    # moj_forms_admin? ||
    # moj_forms_dev? ||
    
    ServiceConfiguration.find_by(
      service_id: service.service_id,
      name: 'APPROVED_FOR_LIVE'
    ).present? ||

    PublishService.find_by(
      service_id: service.service_id,
      deployment_environment: 'production'
    ).present?
  end
  helper_method :can_publish_to_live

  def prod_tab_active?
    
  end
  helper_method :prod_tab_active?

  def declaration_errors
    if @errors.present? 
      if @errors.any?
        byebug
        @errors
      end
    else
      []
    end
  end
  helper_method :declaration_errors

  def show_confirmation
    if @show_confirmation
      @show_confirmation = nil
      return true
    end
  end
  helper_method :show_confirmation

  private

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
    params.permit(
      :authenticity_token,
      :declarations_checkboxes => [],
    ).merge(
      require_authentication: '1',
      username: 'FIXME123',
      password: 'FIXME123',
      deployment_environment: 'production',
      service_id: service.service_id,
      user_id: current_user.id,
      version_id: service.version_id
    )
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
