class FormAnalyticsUpdater < SettingsUpdater
  def create_or_update!
    ActiveRecord::Base.transaction do
      save_form_analytics_config
    end
  end

  def save_form_analytics_config
    settings.config_names.each do |config|
      if settings.enabled? && params(config).present?
        create_or_update_the_service_configuration(config)
      else
        remove_the_service_configuration(config)
      end
    end
  end
end
