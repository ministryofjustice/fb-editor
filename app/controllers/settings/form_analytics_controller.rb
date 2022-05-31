class Settings::FormAnalyticsController < FormController
  before_action :assign_form_objects

  private

  def assign_form_objects
    @form_analytics_dev = FormAnalyticsSettings.new(
      service: service,
      deployment_environment: 'dev'
    )
    @form_analytics_production = FormAnalyticsSettings.new(
      service: service,
      deployment_environment: 'production'
    )
  end
end
