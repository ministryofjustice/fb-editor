require 'csv'

class AutocompleteItems
  include ActiveModel::Model
  attr_accessor :service_id, :component_id, :file

  validates :file, presence: true
  validates_with CsvValidator, unless: proc { |obj| obj.file.blank? }

  def file_headings
    file_contents.first.compact.map(&:downcase)
  end

  def file_values
    file_contents.drop(1)
  end

  private

  def file_contents
    @file_contents ||= CSV.read(file.path)
  rescue CSV::MalformedCSVError
    errors.add(
      I18n.t(
        'activemodel.errors.models.autocomplete_items.incorrect_format'
      )
    )
  end
end
