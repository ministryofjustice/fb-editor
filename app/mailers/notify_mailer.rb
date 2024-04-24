class NotifyMailer < GovukNotifyRails::Mailer
  # Define methods as usual, and set the template and personalisation accordingly
  # Then just use mail() as with any other ActionMailer, with the recipient email.
  before_action do
    @template_ids = Rails.configuration.govuk_notify_templates
  end

  # Report the exception but do not re-raise it, as these errors
  # are not recoverable so it is not useful to retry failed jobs
  # :nocov:
  rescue_from 'Notifications::Client::BadRequestError' do |ex|
    Rails.logger.warn("#{ex} - #{message.to}")
    Sentry.capture_exception(
      ex, contexts: { recipient: { emails: message.to.join(',') } }
    )
  end
  # :nocov:

  protected

  def set_template(name)
    super(@template_ids.fetch(name))
  end
end
