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

  def first_time_publish_to_test(user:, form_name:, form_url:)
    set_template(:first_time_publish_to_test)

    set_personalisation(
      form_name:,
      form_url:
    )

    mail(to: user.email)
  end

  protected

  def set_template(name)
    super(@template_ids.fetch(name))
  end

  def set_email_reply_to(name)
    super(@template_ids.fetch(name))
  end
end
