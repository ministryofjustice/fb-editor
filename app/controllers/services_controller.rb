class ServicesController < ApplicationController
  # before_action :require_user!
  layout 'form', only: :edit

  def index
    @service_creation = ServiceCreation.new
  end

  def create
    @service_creation = ServiceCreation.new(service_creation_params)

    if @service_creation.create
      service_m = MetadataPresenter::Service.new(@service_creation.payload.metadata)
      page = service_m.pages.first
      Thumbnail.new(page: page, service: service_m).create
      redirect_to edit_service_path(@service_creation.service_id)
    else
      render :index
    end
  end

  def edit
    @page_creation = PageCreation.new
  end

  def services
    @services ||= MetadataApiClient::Service.all(user_id: '1234')
  end
  helper_method :services

  private

  def service_creation_params
    params.require(
      :service_creation
    ).permit(:service_name).merge(current_user: current_user)
  end
end
