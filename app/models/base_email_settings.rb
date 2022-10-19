class BaseEmailSettings
  include ActiveModel::Model

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
end
