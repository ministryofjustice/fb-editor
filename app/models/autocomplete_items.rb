require 'csv'

class AutocompleteItems
  include ActiveModel::Model
  attr_accessor :service_id, :component_id, :file

  validates :file, presence: true
  validate :scan_file, :file_size
  validates_with CsvValidator, unless: proc { |obj| obj.file.blank? || obj.has_virus? }

  def file_headings
    file_contents.first
  end

  def file_rows
    file_contents.drop(1)
  end

  def to_partial_path
    'show'
  end

  def file_contents
    @file_contents ||= begin
      utf8_content = File.read(file.path, encoding: 'bom|utf-8')
      contents = utf8_content.strip
      CSV.parse(contents)
    end
    rescue Encoding::CompatibilityError
      errors.add(
        :message,
        I18n.t('activemodel.errors.models.autocomplete_items.encoding_error')
      )
      CSV.parse(utf8_content)
  end

  def has_virus?
    return if file.blank?

    @has_virus ||= MalwareScanner.call(file.path)
  end

  def file_too_big?
    return if file.blank?

    file.size > 1.megabytes
  end

  def scan_file
    if has_virus?
      errors.add(
        :message,
        I18n.t('activemodel.errors.models.autocomplete_items.virus_found', attribute: file.original_filename)
      )
    end
  end

  def file_size
    if file_too_big?
      errors.add(
        :message,
        I18n.t('activemodel.errors.models.autocomplete_items.too_big')
      )
    end
  end
end
