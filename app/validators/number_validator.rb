class NumberValidator < ActiveModel::Validator
  def validate(record)
    if Float(record.value, exception: false).blank?
      record.errors.add(
        :number,
        I18n.t(
          'activemodel.errors.models.number_validation.invalid',
          label: record.label
        )
      )
    end
  end
end
