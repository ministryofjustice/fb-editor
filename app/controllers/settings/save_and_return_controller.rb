class Settings::SaveAndReturnController < FormController
  before_action :assign_form_objects, only: :index

  def index; end

  def create
    @save_and_return = SaveAndReturnSettings.new(
      save_and_return_params.merge(service_id: service.service_id)
    )

    if @save_and_return.valid?
      SaveAndReturnSettingsUpdater.new(
        save_and_return_settings: @save_and_return,
        service_id: service.service_id,
        service_name: service.service_name
      ).create_or_update!

      redirect_to settings_save_and_return_index_path(service_id: service.service_id)
    else
      render :index, status: :unprocessable_entity
    end
  end

  def page_title
    "#{I18n.t('settings.save_and_return.heading')} - Settings - MoJ Forms"
  end
  helper_method :page_title

  private

  def assign_form_objects
    @save_and_return = SaveAndReturnSettings.new(service_id: service.service_id)
  end

  def save_and_return_params
    params.require(:save_and_return_settings).permit(:save_and_return)
  end
end
