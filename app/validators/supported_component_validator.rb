class SupportedComponentValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _value)
    if record.component.present? && !record.component_supported?
      record.errors.add(
        attribute,
        I18n.t("activemodel.errors.models.#{record.model_name.singular}.unsupported")
      )
    end
  end
end
