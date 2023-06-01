class Settings::FormNameUrlController < FormController
  before_action :assign_form_object, only: :index

  def index; end

  def create
    @form_name_url_settings = FormNameUrlSettings.new(service_params)

    if @form_name_url_settings.create
      FormUrlUpdater.new(
        service_id: service.service_id,
        service_slug: params[:service][:service_slug]
      ).create_or_update!

      redirect_to settings_form_name_url_index_path(service.service_id)
    else
      render :index
    end
  end

  private

  def service_params
    params.require(:service).permit(:service_name, :service_slug).merge(
      service_id: service.service_id,
      latest_metadata: service.to_h
    )
  end

  def assign_form_object
    @form_name_url_settings = FormNameUrlSettings.new(
      service_id: service.service_id,
      latest_metadata: service.to_h,
      service_name: service.service_name,
      service_slug:
    )
  end
end
