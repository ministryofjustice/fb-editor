class MaintenanceModeSettings
  include ActiveModel::Model

  attr_accessor :service_id,
                :deployment_environment,
                :maintenance_mode,
                :maintenance_page_heading,
                :maintenance_page_content

  validates :deployment_environment, inclusion: {
    in: Rails.application.config.deployment_environments
  }

  validates :maintenance_page_heading, :maintenance_page_content, presence: true

  def maintenance_mode
    settings_for(:maintenance_mode)
  end

  def maintenance_page_heading
    settings_for(:maintenance_page_heading)
  end

  def maintenance_page_content
    Base64.decode64(settings_for(:maintenance_page_content))
  end

  def settings_for(setting_name)
    params(setting_name).presence ||
      database(setting_name) ||
      default_value(setting_name)
  end

  def database(setting_name)
    ServiceConfiguration.find_by(
      service_id:,
      deployment_environment:,
      name: setting_name.upcase
    ).try(:decrypt_value)
  end

  def default_value(setting_name)
    if setting_name == :maintenance_page_content
      Base64.encode64(I18n.t("presenter.maintenance.#{setting_name}"))
    else
      I18n.t("presenter.maintenance.#{setting_name}")
    end
  end

  def params(setting_name)
    instance_variable_get(:"@#{setting_name}")
  end
end
