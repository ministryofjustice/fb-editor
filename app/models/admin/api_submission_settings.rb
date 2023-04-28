class ApiSubmissionSettings < BaseEmailSettings
  attr_accessor :deployment_environment,
                :service,
                :name,
                :value

  validates :deployment_environment, inclusion: {
    in: Rails.application.config.deployment_environments
  }

  def api_submission_setting_value
    settings_for(:api_submission_setting_value)
  end
end
