class DateValidator < ActiveModel::Validator
  def validate(record)
    Date.strptime(
      "#{record.year}-#{record.month}-#{record.day}",
      '%Y-%m-%d'
    )
  rescue Date::Error
    record.errors.add(
      :date,
      I18n.t(
        'activemodel.errors.models.date_validation.invalid',
        label: record.label
      )
    )
  end
end
