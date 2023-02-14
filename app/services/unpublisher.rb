class Unpublisher
  include ActiveModel::Model
  attr_accessor :publish_service, :platform_environment, :service_slug, :adapter

  MAIN = 'unpublisher.main'.freeze
  STEPS = %w[unpublishing unpublished].freeze

  def call(steps: STEPS)
    ActiveSupport::Notifications.instrument(MAIN) do
      steps.each do |action_name|
        ActiveSupport::Notifications.instrument("unpublisher.#{action_name}") do
          adapter.new(
            publish_service:,
            platform_environment:,
            service_slug:
          ).method(action_name).call
        end
      end
    end
  end
end
