ActionMailer::Base.add_delivery_method(
  :govuk_notify,
  GovukNotifyRails::Delivery,
  api_key: ENV['GOVUK_NOTIFY_API_KEY']
)

# Load the templates set (refer to `config/govuk_notify_templates.yml` for details)
Rails.configuration.govuk_notify_templates = Rails.application.config_for(
  :govuk_notify_templates, env: ENV.fetch('PLATFORM_ENV', 'test')
).with_indifferent_access
