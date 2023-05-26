class FormUrlUpdater
  attr_reader :service_id, :service_slug

  def initialize(service_id:, service_slug:)
    @service_id = service_id
    @service_slug = service_slug
  end

  def create_or_update!
    ActiveRecord::Base.transaction do
      if previous_service_slug.nil? && currently_published?
        save_config_previous_service_slug
      end

      if previous_service_slug.present? && !currently_published?
        remove_previous_service_slug_config
      end

      save_config_service_slug
    end
  end

  private

  def save_config_service_slug
    create_or_update_service_configuration(config: 'SERVICE_SLUG', deployment_environment: 'dev', value: new_service_slug)
    create_or_update_service_configuration(config: 'SERVICE_SLUG', deployment_environment: 'production', value: new_service_slug)
  end

  def save_config_previous_service_slug
    create_or_update_service_configuration(config: 'PREVIOUS_SERVICE_SLUG', deployment_environment: 'dev', value: existing_service_slug_config)
    create_or_update_service_configuration(config: 'PREVIOUS_SERVICE_SLUG', deployment_environment: 'production', value: existing_service_slug_config)
  end

  def remove_previous_service_slug_config
    remove_service_configuration(config: 'PREVIOUS_SERVICE_SLUG', deployment_environment: 'dev')
    remove_service_configuration(config: 'PREVIOUS_SERVICE_SLUG', deployment_environment: 'production')
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

  def remove_service_configuration(config:, deployment_environment:)
    setting = find_or_initialize_setting(config, deployment_environment)
    setting.destroy!
  end

  def new_service_slug
    @new_service_slug ||= begin
      return parameterized_service_slug if unique_service_slug?

      # Replace the last 3 chars with random 3 alpha-numric chars
      parameterized_service_slug.gsub(/.{3}$/, SecureRandom.alphanumeric(3)).downcase
    end
  end

  def parameterized_service_slug
    # parameterize, use first non-numeric char and limit to 57 chars
    @parameterized_service_slug ||= service_slug.parameterize.slice(service_slug.index(/\D/), 57)
  end

  def unique_service_slug?
    all_service_slugs.exclude?(parameterized_service_slug)
  end

  def all_service_slugs
    @all_service_slugs ||= all_existing_service_slugs.concat(all_previous_service_slugs)
  end

  def all_existing_service_slugs
    @all_existing_service_slugs ||= ServiceConfiguration.where(name: 'SERVICE_SLUG').map(&:decrypt_value)
  end

  def all_previous_service_slugs
    @all_previous_service_slugs ||= ServiceConfiguration.where(name: 'PREVIOUS_SERVICE_SLUG').map(&:decrypt_value)
  end

  def existing_service_slug_config
    @existing_service_slug_config ||= ServiceConfiguration.find_by(
      service_id:,
      name: 'SERVICE_SLUG'
    )&.decrypt_value
  end

  def previous_service_slug
    @previous_service_slug ||= ServiceConfiguration.find_by(
      service_id:,
      name: 'PREVIOUS_SERVICE_SLUG'
    )
  end

  def currently_published?
    PublishService.where(
      service_id:,
      deployment_environment: 'dev'
    ).last&.published?
  end
end
