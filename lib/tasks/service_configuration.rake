namespace :service_configuration do
  desc 'Add service configuration to services using the service_id. rake service_configuration:apply["1 2 3"]'
  task :apply, [:ids] => :environment do |_t, args|
    exit if args[:ids].blank?

    ActiveRecord::Base.logger = Logger.new($stdout)

    service_ids = args[:ids].split

    service_ids.each do |service_id|
      ServiceConfigurationGenerator.new(service_id).apply
    end
  end
end

class ServiceConfigurationGenerator
  attr_reader :service_id

  def initialize(service_id)
    @service_id = service_id
  end

  def apply
    if ServiceConfiguration.where(service_id:).count.zero?
      puts(
        "#{'=' * 80}\n Service id #{service_id} does not exist \n#{'=' * 80}\n"
      )
      return
    end

    Rails.application.config.deployment_environments.each do |deployment_environment|
      generate_service_secret(
        deployment_environment:
      )
    end
  end

  def generate_service_secret(deployment_environment:)
    service_configuration = ServiceConfiguration.find_or_initialize_by(
      name: 'SERVICE_SECRET',
      deployment_environment:,
      service_id:
    )

    unless service_configuration.persisted?
      service_configuration.value = SecureRandom.hex(16)
      service_configuration.save!
    end
  end
end
