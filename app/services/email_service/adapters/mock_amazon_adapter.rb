module EmailService
  module Adapters
    class MockAmazonAdapter
      def send_mail(_opts = {})
        Rails.logger.debug 'Mock send to ses'
      end
    end
  end
end
