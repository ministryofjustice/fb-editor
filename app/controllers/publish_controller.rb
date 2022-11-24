class PublishController < FormController
  before_action :assign_form_objects

  def index
    @published_dev = published_dev
    @published_production = published_production
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
      service: service,
      deployment_environment: 'dev',
      service_autocomplete_items: service_autocomplete_items
    )
    @publish_page_presenter_production = PublishingPagePresenter.new(
      service: service,
      deployment_environment: 'production',
      service_autocomplete_items: service_autocomplete_items
    )
  end

  def from_address
    @from_address ||= FromAddress.find_or_initialize_by(service_id: service.service_id)
  end

  def published_dev
    if published_dev?
      {
        url: PublishServicePresenter.new(latest_publish_dev, service).url,
        first: is_first_publish_dev?
      }
    end
  end

  def published_production
    if published_production?
      {
        url: PublishServicePresenter.new(latest_publish_production, service).url,
        first: is_first_publish_production?
      }
    end
  end

  def publishes_dev
    @publishes_dev ||= PublishService.where(
      service_id: service.service_id,
      deployment_environment: 'dev'
    )
  end

  def publishes_production
    @publishes_production ||= PublishService.where(
      service_id: service.service_id,
      deployment_environment: 'production'
    )
  end

  def latest_publish_dev
    publishes_dev&.last
  end

  def latest_publish_production
    publishes_production&.last
  end

  def published_dev?
    latest_publish_dev&.published?
  end

  def published_production?
    latest_publish_production&.published?
  end

  def is_first_publish_dev?
    publishes_dev.count == 1
  end

  def is_first_publish_production?
    publishes_production.count == 1
  end

  def update_form_objects
    if @publish_service_creation.deployment_environment == 'dev'
      @publish_page_presenter_dev.publish_creation = @publish_service_creation
    else
      @publish_page_presenter_production.publish_creation = @publish_service_creation
    end
  end
end
