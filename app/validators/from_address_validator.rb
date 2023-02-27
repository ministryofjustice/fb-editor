class FromAddressValidator < ActiveModel::Validator
  def validate(record)
    user_email = record.from_address.email_address
    domain = user_email.split('@').last

    if user_email.empty?
      record.errors.add(
        :base,
        I18n.t('activemodel.errors.models.reply_to.blank')
      )
    end

    unless user_email.match(URI::MailTo::EMAIL_REGEXP)
      record.errors.add(
        :base,
        I18n.t('activemodel.errors.models.from_address.invalid')
      )
    end

    unless domain.in?(Rails.application.config.allowed_domains)
      record.errors.add(
        :base,
        I18n.t('activemodel.errors.models.reply_to.domain_invalid')
      )
    end
  end
end
