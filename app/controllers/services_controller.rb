class ServicesController < PermissionsController
  layout 'form', only: :edit
  skip_before_action :authorised_access, only: %i[index create]

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
    @show_button = session.delete(:undo)

    flow = PagesFlow.new(service)
    @pages_flow = flow.build
    @publish_warning = SubmissionPagesPresenter.new(service, I18n.t('warnings.pages_flow'))
    @detached_flows = flow.detached_flows
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
end
