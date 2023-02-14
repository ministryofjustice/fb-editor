class FormAnalyticsSettings
  include ActiveModel::Model
  attr_accessor :service_id,
                :enabled_test, :ua_test, :gtm_test, :ga4_test,
                :enabled_live, :ua_live, :gtm_live, :ga4_live

  validate :analytics_present
  validates_with FormAnalyticsValidator

  PLATFORM_DEPLOYMENTS = { 'test' => 'dev', 'live' => 'production' }.freeze
  CONFIGS = { ua: 'UA', ga4: 'GA4', gtm: 'GTM' }.freeze
  PERMITTED_PARAMS = (CONFIGS.keys + [:enabled]).map { |param| [:"#{param}_test", :"#{param}_live"] }.flatten.freeze

  def config_params
    @config_params ||= CONFIGS.keys
  end

  def config_names
    @config_names ||= CONFIGS.values
  end

  def enabled?(environment)
    public_send("enabled_#{environment}") == '1'
  end

  def check_enabled?(environment)
    enabled?(environment) || previously_configured?(PLATFORM_DEPLOYMENTS[environment])
  end

  def saved_param(config, environment)
    instance_param("#{config}_#{environment}") ||
      database(config, PLATFORM_DEPLOYMENTS[environment])
  end

  def instance_param(setting_name)
    instance_variable_get(:"@#{setting_name}")&.upcase&.strip
  end

  def environments
    PLATFORM_DEPLOYMENTS.keys
  end

  def errors_present?(environment, attribute = nil)
    errors[:"form_analytics_settings_#{environment}"].present? ||
      (attribute.present? && errors[attribute].present?)
  end

  private

  def analytics_present
    environments.each do |environment|
      next unless enabled?(environment) && config_params.all? { |param| public_send(:"#{param}_#{environment}").blank? }

      errors.add(
        :"form_analytics_settings_#{environment}",
        I18n.t('activemodel.errors.models.form_analytics_settings.blank')
      )
    end
  end

  def previously_configured?(deployment_environment)
    service_configurations(deployment_environment).any? { |config| config.name.in?(config_names) }
  end

  def service_configurations(deployment_environment)
    ServiceConfiguration.where(
      service_id:,
      deployment_environment:
    )
  end

  def database(setting_name, deployment_environment)
    ServiceConfiguration.find_by(
      service_id:,
      deployment_environment:,
      name: setting_name.upcase
    ).try(:decrypt_value)
  end
end
