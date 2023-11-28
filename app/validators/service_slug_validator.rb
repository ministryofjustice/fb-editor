class ServiceSlugValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.blank?
      return record.errors.add attribute, (
        options[:message] ||
        I18n.t('activemodel.errors.models.service_slug.blank')
      )
    end

    current_service_slug = current_service_slug_config(service_id: record.service_id)
    valid_service_slugs = all_service_slugs - [current_service_slug]

    unless valid_service_slugs.exclude?(value)
      record.errors.add attribute, (
        options[:message] ||
        I18n.t(
          'activemodel.errors.models.service_slug.exists'
        )
      )
    end

    if value.include?(' ')
      record.errors.add attribute, (
        options[:message] ||
        I18n.t(
          'activemodel.errors.models.service_slug.whitespace'
        )
      )
    end

    if value.start_with?(/[0-9]/)
      record.errors.add attribute, (
        options[:message] ||
        I18n.t(
          'activemodel.errors.models.service_slug.starts_with_number'
        )
      )
    end

    if value.match?(/[A-Z]/)
      record.errors.add attribute, (
        options[:message] ||
        I18n.t(
          'activemodel.errors.models.service_slug.contains_uppercase'
        )
      )
    end

    unless value.match?(/^[a-zA-Z0-9\- ]+$/)
      record.errors.add attribute, (
        options[:message] ||
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
      name: 'SERVICE_SLUG',
      deployment_environment: 'dev'
    )&.decrypt_value
  end
end
