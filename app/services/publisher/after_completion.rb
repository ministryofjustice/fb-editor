class Publisher
  class AfterCompletion
    attr_reader :service_provisioner

    delegate :deployment_environment, :service_id, :service_name, :created_by, :form_url,
             to: :service_provisioner

    alias_method :form_name, :service_name

    def initialize(service_provisioner:)
      @service_provisioner = service_provisioner
    end

    def call
      if send_first_publish_to_test_email?
        PublisherMailer.first_time_publish_to_test(
          user:, form_name:, form_url:
        ).deliver_later
      end
    end

    private

    def user
      @user ||= User.find(created_by)
    end

    def send_first_publish_to_test_email?
      return unless deployment_environment.inquiry.dev?

      PublishService.completed.where(
        service_id:, deployment_environment:
      ).one?
    end
  end
end
