class K8sConfigRemovalService
  attr_reader :status

  def initialize(namespace:, targets:)
    @namespace = namespace
    @targets = targets
    @status = []
  end

  def call
    targets.each do |target|
      result = delete(config: target[:config], name: target[:name])
      message = if result.nil?
                  "Failed to delete #{target[:config]} for #{target[:name]}"
                else
                  "Successfully deleted #{target[:config]} for #{target[:name]}"
                end

      Rails.logger.info(message)
      status.push(message)
    end
  end

  private

  attr_writer :status
  attr_reader :namespace, :targets

  def delete(config:, name:)
    Publisher::Utils::Shell.output_of(
      '$(which kubectl)',
      "delete #{config} #{name} -n #{namespace}"
    )
  rescue Publisher::Utils::Shell::CmdFailedError => e
    Sentry.capture_exception(e)
  end
end
