class PublishController < FormController
  before_action :assign_form_objects, :assign_autocomplete_objects

  def index
    @published_dev = published?(service.service_id, 'dev')
    @published_production = published?(service.service_id, 'production')
  end

  def create
    @publish_service_creation = PublishServiceCreation.new(publish_service_params)

    if @publish_service_creation.save
      PublishServiceJob.perform_later(
        publish_service_id: @publish_service_creation.publish_service_id
      )
      redirect_to publish_index_path(service.service_id)
    else
      update_form_objects
      render :index
    end
  end

  private

  def service_autocomplete_items
    MetadataApiClient::Items.all(service_id: service.service_id)
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

  def assign_form_objects
    @publish_page_presenter_dev = PublishingPagePresenter.new(service, 'dev')
    @publish_page_presenter_production = PublishingPagePresenter.new(service, 'production')
  end

  def set_from_address(deployment_environment)
    instance_variable_set(
      :"@from_address_presenter_#{deployment_environment}", FromAddressPresenter.new(
        from_address,
        I18n.t("warnings.from_address.publishing.#{deployment_environment}"),
        service.service_id
      )
    )
  end

  def set_publish_warning(deployment_environment)
    instance_variable_set(
      :"@publish_warning_#{deployment_environment}",
      PublishPresenter.new(service,
      I18n.t("warnings.submission_pages.#{deployment_environment}"))
    )
  end

  def set_publish_creation(deployment_environment)
    instance_variable_set(
      :"@publish_service_creation_#{deployment_environment}", PublishServiceCreation.new(
        service_id: service.service_id,
        deployment_environment: deployment_environment
      )
    )
  end

  def set_submission_presenter(deployment_environment)
    instance_variable_set(
      :"@submission_presenter_#{deployment_environment}",
      SubmissionPresenter.new(
        [
          instance_variable_get(:"@publish_warning_#{deployment_environment}"),
          instance_variable_get(:"@from_address_presenter_#{deployment_environment}")
        ],
        deployment_environment
      )
    )
  end

  def assign_autocomplete_objects
    @autocomplete_warning = AutocompleteItemsPresenter.new(service, service_autocomplete_items)
  end

  def from_address
    @from_address ||= FromAddress.find_or_initialize_by(service_id: service.service_id)
  end

  def published?(service_id, environment)
    PublishService.where(
      service_id: service_id,
      deployment_environment: environment
    ).last&.published?
  end

  def update_form_objects
    @publish_warning = PublishPresenter.new(service)
    if @publish_service_creation.deployment_environment == 'dev'
      @publish_service_creation_dev = @publish_service_creation
    else
      @publish_service_creation_production = @publish_service_creation
    end
  end
end
