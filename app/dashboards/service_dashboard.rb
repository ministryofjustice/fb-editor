require 'administrate/custom_dashboard'
require 'administrate/field/string'

class ServiceDashboard < Administrate::CustomDashboard
  resource 'Services' # used by administrate in the views

  ATTRIBUTE_TYPES = {
    id: Field::String,
    name: Field::String
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    name
  ].freeze

  FORM_ATTRIBUTES = %i[
    id
    name
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
