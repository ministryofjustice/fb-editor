class FormUrlCreation
  attr_reader :service_id, :service_slug

  def initialize(service_id:, service_slug:)
    @service_id = service_id
    @service_slug = service_slug
  end

  def create_or_update!
    ActiveRecord::Base.transaction do
      save_config_service_slug
    end
  end

  private

  def save_config_service_slug
    create_or_update_service_configuration(config: 'SERVICE_SLUG', deployment_environment: 'dev', value: new_service_slug)
    create_or_update_service_configuration(config: 'SERVICE_SLUG', deployment_environment: 'production', value: new_service_slug)
  end

  def create_or_update_service_configuration(config:, deployment_environment:, value:)
    setting = find_or_initialize_setting(config, deployment_environment)
    setting.value = value
    setting.save!
  end

  def find_or_initialize_setting(config, deployment_environment)
    ServiceConfiguration.find_or_initialize_by(
      service_id:,
      deployment_environment:,
      name: config
    )
  end

  def new_service_slug
    return parameterized_service_slug if unique_service_slug?

    # Replace the last 3 chars with random 3 alpha-numric chars
    parameterized_service_slug.gsub(/.{3}$/, SecureRandom.alphanumeric(3)).downcase
  end

  def parameterized_service_slug
    # parameterize, use first non-numeric char and limit to 57 chars
    service_slug.gsub('_', '-').slice(service_slug.index(/\D/), 57).strip.parameterize
  end

  def unique_service_slug?
    all_service_slugs.exclude?(parameterized_service_slug)
  end

  def all_service_slugs
    all_existing_service_slugs.concat(all_previous_service_slugs)
  end

  def all_existing_service_slugs
    ServiceConfiguration.where(name: 'SERVICE_SLUG').map(&:decrypt_value)
  end

  def all_previous_service_slugs
    ServiceConfiguration.where(name: 'PREVIOUS_SERVICE_SLUG').map(&:decrypt_value)
  end

  def previous_service_slug
    ServiceConfiguration.find_by(
      service_id:,
      name: 'PREVIOUS_SERVICE_SLUG'
    )
  end
end
