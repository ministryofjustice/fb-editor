class ServicesController < PermissionsController
  layout 'form', only: :edit
  skip_before_action :authorised_access, only: %i[index create]
  ACCEPTANCE_TEST_USER = 'Acceptance Tests'.freeze

  def index
    @service_creation = ServiceCreation.new
  end

  def create
    @service_creation = ServiceCreation.new(service_creation_params)

    if @service_creation.create
      if current_user.name != ACCEPTANCE_TEST_USER
        FormUrlCreation.new(
          service_id: @service_creation.service_id,
          service_slug: @service_creation.service_name
        ).create_or_update!
      end

      redirect_to edit_service_path(@service_creation.service_id)
    else
      render :index
    end
  end

  def edit
    @undo_redo_button = session.delete(:undo)

    flow = PagesFlow.new(service)
    @pages_flow = flow.build
    @publish_warning = SubmissionPagesPresenter.new(service, I18n.t('warnings.pages_flow'), grid)
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
    ).permit(:service_name).merge(current_user:)
  end

  def page_title
    'Your forms - MoJ Forms Editor'
  end
  helper_method :page_title
end
