class Settings::FormInformationController < FormController
  def index
    @settings = Settings.new(service_name: service.service_name)
  end

  def create
    @settings = Settings.new(service_params)

    if @settings.update
      redirect_to settings_form_information_index_path(service.service_id)
    else
      render :index
    end
  end

  def page_title
    I18n.t('settings.form_information.heading')
  end
  helper_method :page_title

  private

  def service_params
    params.require(:service).permit(:service_name).merge(
      service_id: service.service_id,
      latest_metadata: service.to_h,
      current_user:
    )
  end
end
