MOJ_FORMS_ADMIN = [
  'claire.bowman@digital.justice.gov.uk',
  'sijy.mathew@digital.justice.gov.uk',
  'mark.jefferson@digital.justice.gov.uk',
  'assma.banaris@digital.justice.gov.uk',
  'fabien.marry@digital.justice.gov.uk',
  'natalia.stutter@digital.justice.gov.uk',
  'darren.rooke@digital.justice.gov.uk',
  'daniel.glen@digital.justice.gov.uk'
].freeze

MOJ_FORMS_DEVS = [
  'matt.tei@digital.justice.gov.uk',
  'chris.pymm@digital.justice.gov.uk',
  'hellema.ibrahim@digital.justice.gov.uk',
  'steven.leighton@digital.justice.gov.uk'
].freeze

MOJ_FORMS_TEAM = MOJ_FORMS_ADMIN + MOJ_FORMS_DEVS.freeze

Rails.application.config.moj_forms_admin = MOJ_FORMS_ADMIN
Rails.application.config.moj_forms_devs = MOJ_FORMS_DEVS
Rails.application.config.moj_forms_team = MOJ_FORMS_TEAM
