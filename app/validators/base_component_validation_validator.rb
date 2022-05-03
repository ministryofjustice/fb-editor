class BaseComponentValidationValidator < ActiveModel::Validator
  DEFINITION_BUNDLES = { number: 'number_bundle' }.freeze

  def validate(record)
    bundle = definition_bundle(record.component_type)

    if no_validator_for_component?(bundle, record.validator)
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

  private

  def no_validator_for_component?(bundle, validator)
    component_validations(bundle).exclude?(validator)
  end

  def component_validations(bundle)
    validations_definitions[bundle]['properties']['validation']['properties'].keys
  end

  def definition_bundle(component)
    DEFINITION_BUNDLES[component.to_sym]
  end

  def validations_definitions
    JSON::Validator.schema_for_uri('validations').schema['definitions']
  end
end
