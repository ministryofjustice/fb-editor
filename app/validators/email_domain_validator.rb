class EmailDomainValidator
  ALLOWED_DOMAINS = [
    'justice.gov.uk',
    'digital.justice.gov.uk'
  ].freeze

  def allowed?(email)
    return if email.blank?

    domain = email.split('@').last
    domain.in?(ALLOWED_DOMAINS)
  end
end
