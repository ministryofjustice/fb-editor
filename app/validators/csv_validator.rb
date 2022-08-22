class CsvValidator < ActiveModel::Validator
  def validate(record)
    if record.file_contents
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
      elsif invalid_headings?(record) || record.file_rows.map(&:size).max > 2
        record.errors.add(
          :file,
          I18n.t(
            'activemodel.errors.models.autocomplete_items.incorrect_format'
          )
        )
      elsif empty_value_cell?(record)
        record.errors.add(
          :file,
          I18n.t(
            'activemodel.errors.models.autocomplete_items.empty_value_cell'
          )
        )
      end
    end
  rescue CSV::MalformedCSVError
    record.errors.add(
      :file,
      I18n.t(
        'activemodel.errors.models.autocomplete_items.incorrect_format'
      )
    )
  end

  private

  def not_csv?(record)
    ['text/csv', 'application/csv'].exclude?(record.file.content_type)
  end

  def invalid_headings?(record)
    (record.file_headings.count == 1 && record.file_headings != %w[text]) ||
      (record.file_headings.count == 2 && record.file_headings != %w[text value])
  end

  def empty_value_cell?(record)
    record.file_contents.any? { |cell| cell[1].blank? }
  end
end
