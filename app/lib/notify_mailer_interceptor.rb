class NotifyMailerInterceptor
  class << self
    # Skips Notify mail deliveries when running acceptance tests
    # Can be extended if needed in the future to cover other scenarios

    SKIP_RECIPIENTS = %w[
      fb-acceptance-tests@digital.justice.gov.uk
    ].freeze

    def delivering_email(message)
      return if allowed_recipient?(message.to.first)

      message.perform_deliveries = false
      Rails.logger.info "Interceptor prevented sending email to: #{message.to}"
    end

    private

    def allowed_recipient?(email)
      SKIP_RECIPIENTS.exclude?(email)
    end
  end
end
