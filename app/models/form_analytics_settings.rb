class FormAnalyticsSettings
  include ActiveModel::Model
  include ActiveModel::Validations
  attr_accessor :service_id, :deployment_environment, :enabled, :ua, :gtm, :ga4

  validate :analytics_present, if: :enabled?
  validates_with FormAnalyticsValidator, if: :enabled?

  CONFIGS = { ua: 'UA', gtm: 'GTM', ga4: 'GA4' }.freeze

  def config_params
    @config_params ||= CONFIGS.keys
  end

  def config_names
    @config_names ||= CONFIGS.values
  end

  def enabled?
    enabled == '1'
  end

  def check_enabled?
    enabled? || previously_configured?
  end

  def params(setting_name)
    instance_variable_get(:"@#{setting_name}")&.upcase
  end

  # rubocop:disable Lint/DuplicateMethods
  def ua
    params(:ua) || database(:ua)
  end

  def gtm
    params(:gtm) || database(:gtm)
  end

  def ga4
    params(:ga4) || database(:ga4)
  end
  # rubocop:enable Lint/DuplicateMethods

  private

  def analytics_present
    if config_params.all? { |param| public_send(param).blank? }
      errors.add(
        :form_analytics_settings,
        I18n.t('activemodel.errors.models.form_analytics_settings.blank')
      )
    end
  end

  def previously_configured?
    service_configurations.any? { |config| config.name.in?(config_names) }
  end

  def service_configurations
    ServiceConfiguration.where(
      service_id: service_id,
      deployment_environment: deployment_environment
    )
  end

  def database(setting_name)
    ServiceConfiguration.find_by(
      service_id: service_id,
      deployment_environment: deployment_environment,
      name: CONFIGS[setting_name]
    ).try(:decrypt_value)
  end
end
