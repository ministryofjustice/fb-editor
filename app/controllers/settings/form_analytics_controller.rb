class Settings::FormAnalyticsController < FormController
  before_action :form_analytics_enabled
  before_action :assign_form_object, only: :index

  def index; end

  def create
    @form_analytics = FormAnalyticsSettings.new(
      form_analytics_params.merge(service_id: service.service_id)
    )

    if @form_analytics.valid?
      FormAnalyticsUpdater.new(
        settings: @form_analytics,
        service_id: service.service_id
      ).create_or_update!

      redirect_to settings_form_analytics_path(service_id: service.service_id)
    else
      render :index, status: :unprocessable_entity
    end
  end

  private

  def assign_form_object
    @form_analytics = FormAnalyticsSettings.new(service_id: service.service_id)
  end

  def form_analytics_params
    params.require(:form_analytics_settings)
          .permit(*FormAnalyticsSettings::PERMITTED_PARAMS)
  end

  def form_analytics_enabled
    redirect_to unauthorised_path unless ENV['FORM_ANALYTICS'] == 'enabled'
  end
end
