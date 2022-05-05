class BaseComponentValidationValidator < ActiveModel::Validator
  def validate(record)
    if record.component.supported_validations.exclude?(record.validator)
      record.errors.add(
        :validator,
        I18n.t(
          'activemodel.errors.models.base_component_validation.validator',
          validator: record.validator,
          component: record.component_type
        )
      )
    elsif record.enabled? && record.value.blank?
      record.errors.add(
        :blank,
        I18n.t(
          'activemodel.errors.models.base_component_validation.blank',
          label: record.label
        )
      )
    end
  end
end
