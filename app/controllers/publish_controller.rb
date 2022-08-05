class PublishController < FormController
  before_action :assign_form_objects

  def index
    @published_dev = published?(service.service_id, 'dev')
    @published_production = published?(service.service_id, 'production')
    @publish_warning = PublishPresenter.new(service)
    @autocomplete_warning = AutocompleteItemsPresenter.new(service, service_autocomplete_items)
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
    @publish_service_creation_dev = PublishServiceCreation.new(
      service_id: service.service_id,
      deployment_environment: 'dev'
    )
    @publish_service_creation_production = PublishServiceCreation.new(
      service_id: service.service_id,
      deployment_environment: 'production'
    )
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
