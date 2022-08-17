require 'csv'

class AutocompleteItems
  include ActiveModel::Model
  attr_accessor :service_id, :component_id, :file

  validates :file, presence: true
  validate :scan_file
  validates_with CsvValidator, unless: proc { |obj| obj.file.blank? || obj.has_virus? }

  def file_headings
    file_contents.first.compact.map(&:downcase)
  end

  def file_values
    file_contents.drop(1)
  end

  def to_partial_path
    'show'
  end

  def file_contents
    @file_contents ||= CSV.read(file.path)
  end

  def has_virus?
    return if file.blank?

    @has_virus ||= MalwareScanner.call(file.path)
  end

  def scan_file
    if has_virus?
      errors.add(:message, I18n.t('activemodel.errors.models.autocomplete_items.virus_found', attribute: file.original_filename))
    end
  end
end
