class EmailSettings < BaseEmailSettings
  attr_accessor :deployment_environment,
                :service,
                :send_by_email,
                :service_email_output,
                :service_email_subject,
                :service_email_body,
                :service_email_pdf_heading,
                :service_email_pdf_subheading,
                :service_csv_output

  attr_reader :send_by_email_dev,
              :send_by_email_production

  validates :deployment_environment, inclusion: {
    in: Rails.application.config.deployment_environments
  }

  validates :service_email_output, presence: true, if: :send_by_email?

  validates :service_email_output, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true, if: :send_by_email?

  validates_with DomainValidator, if: :send_by_email?

  def send_by_email_checked?
    send_by_email? || SubmissionSetting.find_by(
      service_id: service.service_id,
      deployment_environment:
    ).try(:send_email?)
  end

  def send_by_email?
    send_by_email == '1'
  end

  def service_email_output
    settings_for(:service_email_output)
  end

  def service_email_subject
    settings_for(:service_email_subject)
  end

  def service_email_body
    settings_for(:service_email_body)
  end

  def service_email_pdf_heading
    settings_for(:service_email_pdf_heading)
  end

  def service_email_pdf_subheading
    settings_for(:service_email_pdf_subheading)
  end

  def service_csv_output?
    service_csv_output == '1'
  end

  def service_csv_output_checked?
    service_csv_output? || SubmissionSetting.find_by(
      service_id: service.service_id,
      deployment_environment:
    ).try(:service_csv_output?)
  end
end
