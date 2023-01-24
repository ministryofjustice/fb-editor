class DomainValidator < ActiveModel::Validator
  def validate(record)
    user_email = record.service_email_output
    domain = user_email.split('@').last
    unless domain.in?(Rails.application.config.allowed_domains)
      record.errors.add(
        :base,
        I18n.t('activemodel.errors.models.email_settings.domain_invalid')
      )
    end
  end
end
