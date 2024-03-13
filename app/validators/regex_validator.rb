class RegexValidator < ActiveModel::Validator
  def validate(record)
    Regexp.new(record.value)
  rescue RegexpError
    record.errors.add(
      :pattern,
      I18n.t('activemodel.errors.models.string_regex_pattern.invalid')
    )
  end
end
