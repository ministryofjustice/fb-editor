class CsvValidator < ActiveModel::Validator
  def validate(record)
    return if record.file.blank?

    unless csv?(record) && valid_headings?(record)
      record.errors.add(
        :file,
        I18n.t(
          'activemodel.errors.models.csv_validation.invalid'
        )
      )
    end
  end

  private

  def csv?(record)
    record.file.content_type == 'text/csv' || record.file.content_type == 'application/csv'
  end

  def valid_headings?(record)
    headings = CSV.read(record.file)[0]
    headings.include?('Text')
  end
end
