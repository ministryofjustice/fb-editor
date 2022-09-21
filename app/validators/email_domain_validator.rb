class EmailDomainValidator < ActiveModel::Validator
  ALLOWED_DOMAINS = [
    'justice.gov.uk',
    'digital.justice.gov.uk'
  ].freeze

  def validate(record)
    return if record.email.blank?

    unless allowed_domain?(record.email)
      record.errors.add(:base, I18n.t('activemodel.errors.models.from_address.invalid_domain'))
    end
  end

  private

  def allowed_domain?(email)
    domain = email.split('@').last
    domain.in?(ALLOWED_DOMAINS)
  end
end
