class NotifyMailerInterceptor
  class << self
    # Skips Notify mail deliveries when running acceptance tests
    # Can be extended if needed in the future to cover other scenarios

    def delivering_email(message)
      if acceptance_tests?(message)
        message.perform_deliveries = false
        Rails.logger.info "Interceptor prevented sending email to: #{acceptance_test_email}"
      end
    end

    private

    def acceptance_tests?(message)
      message.to.include?(acceptance_test_email)
    end

    def acceptance_test_email
      ENV['ACCEPTANCE_TESTS_USER']
    end
  end
end
