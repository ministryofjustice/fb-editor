class ConfirmationEmailSettings
  include ActiveModel::Model
  attr_accessor :deployment_environment,
                :service,
                :from_address,
                :send_by_confirmation_email,
                :confirmation_email_output,
                :confirmation_email_subject,
                :confirmation_email_body

  attr_reader :send_by_confirmation_email_dev,
              :send_by_confirmation_email_production

  validates :deployment_environment, inclusion: {
    in: Rails.application.config.deployment_environments
  }

  validates :confirmation_email_output, presence: true, if: :send_by_confirmation_email?

  validates :confirmation_email_output, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  def send_by_confirmation_email_checked?
    send_by_confirmation_email? || SubmissionSetting.find_by(
      service_id: service.service_id,
      deployment_environment: deployment_environment
    ).try(:send_confirmation_email?)
  end

  def send_by_confirmation_email?
    send_by_confirmation_email == '1'
  end

  def confirmation_email_output
    settings_for(:confirmation_email_output)
  end

  def service_email_from
    from_address.email_address
  end

  def confirmation_email_subject
    settings_for(:confirmation_email_subject)
  end

  def confirmation_email_body
    settings_for(:confirmation_email_body)
  end

<<<<<<< HEAD
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

  def email_component_ids
    @email_component_ids ||= email_components.map(&:id)
  end

  def email_components
    @email_components ||=
      components.select do |component|
        component.type == 'email'
      end
  end

  private

  def components
    @components ||= service.pages.map(&:components).flatten
  end
end
