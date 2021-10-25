class K8sConfigRemovalService
  attr_reader :status

  def initialize(namespace:, targets: [])
    @namespace = namespace
    @targets = targets
    @status = []
  end

  def call
    targets.each do |target|
      delete(config: target[:config], name: target[:name])
      message = "Successfully deleted #{target[:config]} for #{target[:name]}"
    rescue Publisher::Utils::Shell::CmdFailedError
      message = "Failed to delete #{target[:config]} for #{target[:name]}"
    ensure
      Rails.logger.info(message)
      status.push(message)
    end
  end

  def delete(config:, name:)
    Publisher::Utils::Shell.output_of(
      '$(which kubectl)',
      "delete #{config} #{name} -n #{namespace}"
    )
  rescue Publisher::Utils::Shell::CmdFailedError => e
    Sentry.capture_exception(e)
    raise e
  end

  private

  attr_writer :status
  attr_reader :namespace, :targets
end
