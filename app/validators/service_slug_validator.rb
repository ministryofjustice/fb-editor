class ServiceSlugValidator < ActiveModel::Validator
  def validate(record)
    current_service_slug = current_service_slug_config(service_id: record.service_id)
    valid_service_slugs = all_service_slugs - [current_service_slug]

    unless valid_service_slugs.exclude?(record.service_slug)
      record.errors.add(
        :base,
        I18n.t(
          'activemodel.errors.models.service_slug.exists'
        )
      )
    end

    if record.service_slug.include?(' ')
      record.errors.add(
        :base,
        I18n.t(
          'activemodel.errors.models.service_slug.whitespace'
        )
      )
    end

    if record.service_slug.start_with?(/[0-9]/)
      record.errors.add(
        :base,
        I18n.t(
          'activemodel.errors.models.service_slug.starts_with_number'
        )
      )
    end

    if record.service_slug.match?(/[A-Z]/)
      record.errors.add(
        :base,
        I18n.t(
          'activemodel.errors.models.service_slug.contains_uppercase'
        )
      )
    end

    unless record.service_slug.match?(/^[a-zA-Z0-9-]+$/)
      record.errors.add(
        :base,
        I18n.t(
          'activemodel.errors.models.service_slug.special_characters'
        )
      )
    end
  end

  private

  def all_service_slugs
    @all_service_slugs ||= all_existing_service_slugs.concat(all_previous_service_slugs)
  end

  def all_existing_service_slugs
    @all_existing_service_slugs ||= ServiceConfiguration.where(name: 'SERVICE_SLUG').map(&:decrypt_value)
  end

  def all_previous_service_slugs
    @all_previous_service_slugs ||= ServiceConfiguration.where(name: 'PREVIOUS_SERVICE_SLUG').map(&:decrypt_value)
  end

  def current_service_slug_config(service_id:)
    ServiceConfiguration.find_by(
      service_id:,
      name: 'SERVICE_SLUG'
    )&.decrypt_value
  end
end
