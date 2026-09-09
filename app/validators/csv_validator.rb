class CsvValidator < ActiveModel::Validator
  def validate(record)
    if record.file_contents
      headings = record.file_headings&.compact&.map(&:downcase)

      if not_csv?(record)
        record.errors.add(
          :file,
          I18n.t(
            'activemodel.errors.models.autocomplete_items.invalid_type'
          )
        )
      elsif record.file_rows.empty?
        record.errors.add(
          :file,
          I18n.t(
            'activemodel.errors.models.autocomplete_items.empty'
          )
        )
      elsif invalid_headings?(record, headings) || record.file_contents.first.count > 2
        record.errors.add(
          :file,
          I18n.t(
            'activemodel.errors.models.autocomplete_items.invalid_headings'
          )
        )
      elsif empty_value_cell?(record, headings) || empty_text_cell?(record)
        record.errors.add(
          :file,
          I18n.t(
            'activemodel.errors.models.autocomplete_items.empty_value_cell'
          )
        )
      end
    end
  rescue CSV::MalformedCSVError, Encoding::CompatibilityError
    record.errors.add(
      :file,
      I18n.t(
        'activemodel.errors.models.autocomplete_items.incorrect_format'
      )
    )
  end

  private

  def not_csv?(record)
    !record.file.original_filename.end_with?('.csv') &&
      ['text/csv', 'application/csv', 'application/vnd.ms-excel'].exclude?(record.file.content_type)
  end

  def invalid_headings?(record, headings)
    case number_of_columns(record)
    when 1
      headings != %w[text]
    when 2
      headings != %w[text value]
    end
  end

  def number_of_columns(record)
    record.file_rows.map(&:count).max
  end

  def empty_value_cell?(record, headings)
    record.file_contents.any? { |cell| cell[1].blank? } if headings.count == 2
  end

  def empty_text_cell?(record)
    record.file_contents.any? { |cell| cell[0].blank? }
  end
end
