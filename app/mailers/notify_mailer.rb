class NotifyMailer < GovukNotifyRails::Mailer
  # Define methods as usual, and set the template and personalisation accordingly
  # Then just use mail() as with any other ActionMailer, with the recipient email.
  before_action do
    @template_ids = Rails.configuration.govuk_notify_templates
  end

  # :nocov:
  rescue_from 'Notifications::Client::BadRequestError' do |message|
    Rails.logger.warn message.to_s
  end
  # :nocov:

  protected

  def set_template(name)
    super(@template_ids.fetch(name))
  end
end
