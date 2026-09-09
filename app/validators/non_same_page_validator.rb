class NonSamePageValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _value)
    if record.component.present? && !record.component_on_different_page?
      record.errors.add(
        attribute,
        I18n.t("activemodel.errors.models.#{record.model_name.singular}.same_page")
      )
    end
  end
end
