class RegexValidator < ActiveModel::Validator
  DELIMITER = '/'.freeze
  OPTIONS = %w[i x m o].freeze

  def validate(record)
    if record.value.first == DELIMITER || record.value.last == DELIMITER
      record.errors.add(
        :pattern,
        I18n.t('activemodel.errors.models.string_regex_pattern.remove_delimiter')
      )
    end

    if OPTIONS.include?(record.value.split('/').last)
      record.errors.add(
        :pattern,
        I18n.t('activemodel.errors.models.string_regex_pattern.remove_options')
      )
    end

    Regexp.new(record.value)
  rescue RegexpError
    record.errors.add(
      :pattern,
      I18n.t('activemodel.errors.models.string_regex_pattern.invalid')
    )
  end
end
