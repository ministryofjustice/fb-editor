MOJ_FORMS_DEVS = [
  'brendan.butler@digital.justice.gov.uk',
  'matt.tei@digital.justice.gov.uk',
  'natalie.seeto@digital.justice.gov.uk',
  'steven.burnell@digital.justice.gov.uk',
  'tomas.destefi@digital.justice.gov.uk'
].freeze

MOJ_FORMS_TEAM = ([
  'ajiri.owuasu@digital.justice.gov.uk',
  'alex.nash@digital.justice.gov.uk',
  'claire.bowman@digital.justice.gov.uk',
  'fabien.marry@digital.justice.gov.uk',
  'mark.jefferson@digital.justice.gov.uk',
  'rebecca.faulkner@digital.justice.gov.uk',
  'sijy.mathew@digital.justice.gov.uk'
] + MOJ_FORMS_DEVS).freeze

Rails.application.config.moj_forms_team = MOJ_FORMS_TEAM
Rails.application.config.moj_forms_devs = MOJ_FORMS_DEVS
