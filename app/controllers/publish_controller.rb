class PublishController < FormController
  before_action :assign_form_objects

  def index
    @published_dev = PublishServicePresenter.new(publishes_dev, service)
    @published_production = PublishServicePresenter.new(publishes_production, service)
  end

  def create
    if published_form_uses_previous_slug?(publish_service_params[:deployment_environment])
      unpublish_service = published(publish_service_params[:deployment_environment])
      version_metadata = get_version_metadata(unpublish_service)

      unpublish_service_creation = PublishServiceCreation.new(
        service_id: service.service_id,
        version_id: version_metadata['version_id'],
        deployment_environment: publish_service_params[:deployment_environment],
        user_id: current_user.id
      )

      UnpublishServiceJob.perform_later(
        publish_service_id: unpublish_service_creation.publish_service_id,
        service_slug: previous_service_slug
      )
    end

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

  def assign_form_objects
    @publish_page_presenter_dev = PublishingPagePresenter.new(
      service:,
      deployment_environment: 'dev',
      service_autocomplete_items:
    )
    @publish_page_presenter_production = PublishingPagePresenter.new(
      service:,
      deployment_environment: 'production',
      service_autocomplete_items:
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

  def published(deployment_environment)
    return if previous_service_slug.nil?

    PublishService.where(
      service_id: @service.service_id,
      deployment_environment:
    ).completed.desc.first
  end

  def previous_service_slug
    @previous_service_slug ||= ServiceConfiguration.find_by(
      service_id: service.service_id,
      name: 'PREVIOUS_SERVICE_SLUG'
    )&.decrypt_value
  end

  def published_form_uses_previous_slug?(deployment_environment)
    published(deployment_environment).present? && previous_service_slug.present?
  end
end
