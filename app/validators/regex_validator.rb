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
    if record.value.split('/').last.chars.to_set.subset?(OPTIONS.to_set)
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
