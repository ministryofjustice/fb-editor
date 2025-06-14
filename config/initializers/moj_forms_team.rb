MOJ_FORMS_ADMIN = %w[
  claire.bowman@digital.justice.gov.uk
  sijy.mathew@digital.justice.gov.uk
  mark.jefferson@digital.justice.gov.uk
  assma.banaris@digital.justice.gov.uk
  fabien.marry@digital.justice.gov.uk
  darren.rooke@digital.justice.gov.uk
  daniel.glen@digital.justice.gov.uk
  polly.parker@digital.justice.gov.uk
  andrew.altwasser@digital.justice.gov.uk
  deepika.patel@digital.justice.gov.uk
  sijy.mathew1@justice.gov.uk
  Deepika.Patel@justice.gov.uk
  Andrew.Altwasser@justice.gov.uk
  Rhian.Townsend@justice.gov.uk
  Mark.Jefferson1@justice.gov.uk
].freeze

MOJ_FORMS_DEVS = %w[
  matt.tei@digital.justice.gov.uk
  Matthew.Tei@Justice.gov.uk
  chris.pymm@digital.justice.gov.uk
  hellema.ibrahim@digital.justice.gov.uk
  steven.leighton@digital.justice.gov.uk
  steven.leighton1@justice.gov.uk
  jesus.laiz@digital.justice.gov.uk
  hettie.street@digital.justice.gov.uk
  Hettie.Street@justice.gov.uk
  Nick.Preddy@justice.gov.uk
  meena.modhvadia@digital.justice.gov.uk
  Meena.Modhvadia@justice.gov.uk
].freeze

MOJ_FORMS_TEAM = MOJ_FORMS_ADMIN + MOJ_FORMS_DEVS.freeze

Rails.application.config.moj_forms_admin = MOJ_FORMS_ADMIN
Rails.application.config.moj_forms_devs = MOJ_FORMS_DEVS
Rails.application.config.moj_forms_team = MOJ_FORMS_TEAM
