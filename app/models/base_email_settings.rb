class BaseEmailSettings
  include ActiveModel::Model

  REFERENCE_NUMBER_PLACEHOLDER = '{{reference_number_sentence}}'.freeze

  def settings_for(setting_name)
    params(setting_name).presence ||
      database(setting_name) ||
      default_value(setting_name)
  end

  def database(setting_name)
    ServiceConfiguration.find_by(
      service_id: service.service_id,
      deployment_environment: deployment_environment,
      name: setting_name.upcase
    ).try(:decrypt_value)
  end

  def default_value(setting_name)
    I18n.t("default_values.#{setting_name}", service_name: service.service_name)
  end

  def params(setting_name)
    instance_variable_get(:"@#{setting_name}")
  end

  def service_email_from
    from_address.email_address
  end

  def reference_number_enabled?
    ServiceConfiguration.find_by(service_id: service.service_id, deployment_environment: deployment_environment, name: 'REFERENCE_NUMBER').present?
  end

  def insert_reference_number_sentence(setting, placeholder)
    setting.gsub(REFERENCE_NUMBER_PLACEHOLDER, placeholder)
  end

  def remove_reference_number_sentence(setting)
    setting.gsub(REFERENCE_NUMBER_PLACEHOLDER, '')
  end

  def substitute_placeholder(setting, placeholder)
    if reference_number_enabled?
      insert_reference_number_sentence(setting, placeholder)
    else
      remove_reference_number_sentence(setting)
    end
  end
end
