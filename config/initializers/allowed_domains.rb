ALLOWED_DOMAINS = [
  'justice.gov.uk',
  'digital.justice.gov.uk',
  'cica.gov.uk',
  'ccrc.gov.uk',
  'judicialappointments.gov.uk',
  'judicialombudsman.gov.uk',
  'ospt.gov.uk',
  'gov.sscl.com',
  'hmcts.net'
].freeze

Rails.application.config.allowed_domains = ALLOWED_DOMAINS
