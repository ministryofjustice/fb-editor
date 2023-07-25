class MaxFilesValidator < ActiveModel::Validator
  def validate(record)
    if Float(record.value, exception: false).blank?
      return record.errors.add(
        :number,
        I18n.t(
          'activemodel.errors.models.number_validation.invalid',
          label: record.label
        )
      )
    end

    if record.value.to_i < 1
      record.errors.add(
        :number,
        I18n.t(
          'activemodel.errors.models.max_files_validation.too_small',
          label: record.label
        )
      )
    end

    if record.value.to_i > 10
      record.errors.add(
        :number,
        I18n.t(
          'activemodel.errors.models.max_files_validation.too_big',
          label: record.label
        )
      )
    end
  end
end
