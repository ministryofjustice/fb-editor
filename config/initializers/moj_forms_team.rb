MOJ_FORMS_ADMIN = %w[
  mark.jefferson@digital.justice.gov.uk
  daniel.glen@digital.justice.gov.uk
  polly.parker@digital.justice.gov.uk
  andrew.altwasser@digital.justice.gov.uk
  deepika.patel@digital.justice.gov.uk
  Deepika.Patel@justice.gov.uk
  Andrew.Altwasser@justice.gov.uk
  Rhian.Townsend@justice.gov.uk
  Mark.Jefferson1@justice.gov.uk
  Edwin.Bajomo@justice.gov.uk
].freeze

MOJ_FORMS_DEVS = %w[
  matt.tei@digital.justice.gov.uk
  Matthew.Tei@Justice.gov.uk
  Nick.Preddy@Justice.gov.uk
  meena.modhvadia@digital.justice.gov.uk
  Meena.Modhvadia@justice.gov.uk
  Ripan.Kumar@justice.gov.uk
].freeze

MOJ_FORMS_TEAM = MOJ_FORMS_ADMIN + MOJ_FORMS_DEVS.freeze

Rails.application.config.moj_forms_admin = MOJ_FORMS_ADMIN
Rails.application.config.moj_forms_devs = MOJ_FORMS_DEVS
Rails.application.config.moj_forms_team = MOJ_FORMS_TEAM
