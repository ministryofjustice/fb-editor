class LegacyServiceNameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    legacy_service_names = LegacyServiceName.pluck(:name)

    if value.in?(legacy_service_names)
      record.errors.add(attribute, :taken)
    end
  end
end
