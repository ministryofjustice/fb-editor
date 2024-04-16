require 'administrate/base_dashboard'

class AnnouncementDashboard < Administrate::BaseDashboard
  DATETIME_FORMAT = '%d/%m/%Y %H:%M:%S %Z'.freeze
  DATE_FORMAT = '%d/%m/%Y'.freeze

  ATTRIBUTE_TYPES = {
    id: Field::String,
    created_by: Field::BelongsTo,
    revoked_by: Field::BelongsTo,
    created_at: Field::DateTime.with_options(format: DATETIME_FORMAT),
    updated_at: Field::DateTime.with_options(format: DATETIME_FORMAT),
    revoked_at: Field::DateTime.with_options(format: DATETIME_FORMAT),
    date_from: Field::Date.with_options(format: DATE_FORMAT),
    date_to: Field::Date.with_options(format: DATE_FORMAT),
    title: Field::String.with_options(searchable: false),
    content: Field::Text.with_options(searchable: true)
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    created_at
    date_from
    date_to
    title
    content
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    created_at
    created_by
    revoked_at
    revoked_by
    updated_at
    title
    content
    date_from
    date_to
  ].freeze

  FORM_ATTRIBUTES = %i[
    title
    content
    date_from
    date_to
  ].freeze
end
