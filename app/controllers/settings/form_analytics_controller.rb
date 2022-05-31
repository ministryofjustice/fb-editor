class Settings::FormAnalyticsController < FormController
  before_action :assign_form_objects

  def create
    @form_analytics = FormAnalyticsSettings.new(form_analytics_params.merge(service_id: service.service_id))

    if @form_analytics.valid?
      FormAnalyticsUpdater.new(
        settings: @form_analytics,
        service_id: service.service_id
      ).create_or_update!

      redirect_to settings_form_analytics_path(service_id: service.service_id)
    else
      if form_analytics_params[:deployment_environment] == 'dev'
        @form_analytics_dev = @form_analytics
      else
        @form_analytics_production = @form_analytics
      end
      render :index, status: :unprocessable_entity
    end
  end

  private

  def assign_form_objects
    @form_analytics_dev = FormAnalyticsSettings.new(
      deployment_environment: 'dev',
      service_id: service.service_id
    )
    @form_analytics_production = FormAnalyticsSettings.new(
      deployment_environment: 'production',
      service_id: service.service_id
    )
  end

  def form_analytics_params
    params.require(:form_analytics_settings)
          .permit(
            :deployment_environment,
            :enabled,
            *FormAnalyticsSettings::CONFIGS.keys
          )
  end
end
