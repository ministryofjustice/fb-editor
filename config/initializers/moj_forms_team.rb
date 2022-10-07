MOJ_FORMS_ADMIN = [
  'claire.bowman@digital.justice.gov.uk',
  'sijy.mathew@digital.justice.gov.uk',
  'mark.jefferson@digital.justice.gov.uk'
].freeze

MOJ_FORMS_DEVS = [
  'brendan.butler@digital.justice.gov.uk',
  'matt.tei@digital.justice.gov.uk',
  'natalie.seeto@digital.justice.gov.uk',
  'chris.pymm@digital.justice.gov.uk',
  'hellema.ibrahim@digital.justice.gov.uk'
].freeze

MOJ_FORMS_TEAM = MOJ_FORMS_ADMIN + MOJ_FORMS_DEVS + [
  'assma.banaris@digital.justice.gov.uk',
  'fabien.marry@digital.justice.gov.uk',
  'howard.davies@digital.justice.gov.uk'
].freeze

Rails.application.config.moj_forms_admin = MOJ_FORMS_ADMIN
Rails.application.config.moj_forms_devs = MOJ_FORMS_DEVS
Rails.application.config.moj_forms_team = MOJ_FORMS_TEAM
