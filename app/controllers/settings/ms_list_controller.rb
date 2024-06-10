class Settings::MsListController < FormController
  before_action :assign_form_objects

  def create
    @ms_list_settings = MsListSetting.new(
      ms_list_settings_params.merge(service:)
    )

    if @ms_list_settings.valid?
      MsListSettingsUpdater.new(
        ms_list_settings: @ms_list_settings,
        service:
      ).create_or_update!

      redirect_to settings_ms_list_index_path(service_id: service.service_id)
    else
      if ms_list_settings_params[:deployment_environment] == 'dev'
        @ms_list_settings_dev = @ms_list_settings
      else
        @ms_list_settings_production = @ms_list_settings
      end
      render :index, status: :unprocessable_entity
    end
  end

  def ms_list_settings_params
    params.require(:ms_list_setting).permit(
      :deployment_environment,
      :send_to_ms_list,
      :ms_site_id
    )
  end

  def assign_form_objects
    @ms_list_settings_dev = MsListSetting.new(
      service:,
      deployment_environment: 'dev'
    )
    @ms_list_settings_production = MsListSetting.new(
      service:,
      deployment_environment: 'production'
    )
  end

  def human_readable_list_name(deployment_environment)
    "#{service.service_name}-#{deployment_environment}-#{service.version_id}"
  end
  helper_method :human_readable_list_name

  def human_readable_drive_name(deployment_environment)
    "#{service.service_name}-#{deployment_environment}-#{service.version_id}-attachments"
  end
  helper_method :human_readable_drive_name
end
