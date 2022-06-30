class AutocompleteItems
  include ActiveModel::Model
  attr_accessor :service_id, :component_id, :file
  validates :file, presence: true
  validates_with CsvValidator
  
end
