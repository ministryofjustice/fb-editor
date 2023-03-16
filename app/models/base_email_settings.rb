class BaseEmailSettings
  include ActiveModel::Model
  include ContentSubstitutorHelper

  def settings_for(setting_name)
    return '' if setting_name == :confirmation_email_reply_to && !params(setting_name).nil? && params(setting_name).empty?

    params(setting_name).presence ||
      database(setting_name) ||
      default_value(setting_name)
  end

  def database(setting_name)
    ServiceConfiguration.find_by(
      service_id: service.service_id,
      deployment_environment:,
      name: setting_name.upcase
    ).try(:decrypt_value)
  end

  def default_value(setting_name)
    initial_value = content_substitutor.assign(setting_name)

    return initial_value if initial_value.present?

    I18n.t("default_values.#{setting_name}", service_name: service.service_name)
  end

  def params(setting_name)
    instance_variable_get(:"@#{setting_name}")
  end
end
