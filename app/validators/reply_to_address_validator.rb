class ReplyToAddressValidator < ActiveModel::Validator
  def validate(record)
    return if ENV['REPLY_TO'] != 'enabled'

    user_email = record.confirmation_email_reply_to
    domain = user_email.split('@').last

    if user_email.empty?
      record.errors.add(
        :confirmation_email_reply_to,
        I18n.t('activemodel.errors.models.reply_to.blank')
      )
    end

    unless user_email.match(URI::MailTo::EMAIL_REGEXP)
      record.errors.add(
        :confirmation_email_reply_to,
        I18n.t('activemodel.errors.models.from_address.invalid')
      )
    end

    unless domain.in?(Rails.application.config.allowed_domains)
      record.errors.add(
        :confirmation_email_reply_to,
        I18n.t('activemodel.errors.models.reply_to.domain_invalid')
      )
    end
  end
end
