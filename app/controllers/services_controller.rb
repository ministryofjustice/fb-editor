class ServicesController < PermissionsController
  layout 'form', only: :edit

  before_action :create_flow, only: [:edit]

  def index
    @service_creation = ServiceCreation.new
  end

  def create
    @service_creation = ServiceCreation.new(service_creation_params)

    if @service_creation.create
      redirect_to edit_service_path(@service_creation.service_id)
    else
      render :index
    end
  end

  def edit
    @page_creation = PageCreation.new
  end

  def services
    @services ||= MetadataApiClient::Service.all(user_id: current_user.id)
  end
  helper_method :services

  private

  def service_creation_params
    params.require(
      :service_creation
    ).permit(:service_name).merge(current_user: current_user)
  end

  def create_flow
    if service.flow.blank?
      ServiceUpdater.new(service.metadata).tap do |service_updater|
        service_updater.create_flow
        service_updater.update
      end
    end
  end
end
