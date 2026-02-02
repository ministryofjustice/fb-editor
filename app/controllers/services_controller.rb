class ServicesController < PermissionsController
  skip_before_action :authorised_access, only: %i[index create new]
  ACCEPTANCE_TEST_USER = 'Acceptance Tests'.freeze

  def index
    @service_creation = ServiceCreation.new
  end

  def new
    @service_creation = ServiceCreation.new
  end

  def create
    @service_creation = ServiceCreation.new(service_creation_params)

    if @service_creation.create
      session.delete(:questionnaire_answers)
      if current_user.name != ACCEPTANCE_TEST_USER
        FormUrlCreation.new(
          service_id: @service_creation.service_id,
          service_slug: @service_creation.service_name
        ).create_or_update!
      end

      redirect_to edit_service_path(@service_creation.service_id)
    elsif session[:questionnaire_answers].present?
      render :new
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
    params.tap do |p|
      p[:service_creation] ||= {}
      p[:service_creation][:questionnaire] ||= session[:questionnaire_answers]
    end
    params.require(
      :service_creation
    ).permit(:service_name, questionnaire: {}).merge(current_user:)
  end

  def page_title
    if request.path =~ /edit/
      "Pages flow - #{service.service_name} - MoJ Forms"
    else
      'Your forms - MoJ Forms'
    end
  end
  helper_method :page_title
end
