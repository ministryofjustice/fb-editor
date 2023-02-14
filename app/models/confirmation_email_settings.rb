class ConfirmationEmailSettings < BaseEmailSettings
  attr_accessor :deployment_environment,
                :service,
                :from_address,
                :send_by_confirmation_email,
                :confirmation_email_component_id,
                :confirmation_email_subject,
                :confirmation_email_body

  attr_reader :send_by_confirmation_email_dev,
              :send_by_confirmation_email_production

  validates :deployment_environment, inclusion: {
    in: Rails.application.config.deployment_environments
  }

  validates :confirmation_email_component_id, presence: true, if: :send_by_confirmation_email?

  def send_by_confirmation_email_checked?
    send_by_confirmation_email? || SubmissionSetting.find_by(
      service_id: service.service_id,
      deployment_environment:
    ).try(:send_confirmation_email?)
  end

  def send_by_confirmation_email?
    send_by_confirmation_email == '1'
  end

  def confirmation_email_component_id
    settings_for(:confirmation_email_component_id)
  end

  def confirmation_email_subject
    settings_for(:confirmation_email_subject)
  end

  def confirmation_email_body
    settings_for(:confirmation_email_body)
  end

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
