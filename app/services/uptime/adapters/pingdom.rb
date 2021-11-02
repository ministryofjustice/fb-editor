class Uptime
  module Adapters
    class Pingdom
      API_URL = 'https://api.pingdom.com/api/3.1'.freeze
      CHECKS = 'checks'.freeze
      SUBSCRIPTION = 'uptime.pingdom'.freeze
      TIMEOUT = 10

      attr_reader :connection

      delegate :get, :post, :put, :delete, to: :connection

      def initialize(root_url: API_URL)
        @connection = Faraday.new(root_url) do |conn|
          conn.request :json
          conn.request(:authorization, 'Bearer', ENV['PINGDOM_TOKEN'])
          conn.response :json
          conn.response :raise_error
          conn.use :instrumentation, name: SUBSCRIPTION
          conn.options[:open_timeout] = TIMEOUT
          conn.options[:timeout] = TIMEOUT
        end
      end

      def create(service_name, host)
        post(CHECKS, payload(service_name, host))
      end

      def update(id, service_name, host)
        put("#{CHECKS}/#{id}", payload(service_name, host))
      end

      def destroy(id)
        delete("#{CHECKS}/#{id}")
      end

      private

      def payload(service_name, host)
        {
          name: "Form Builder - #{service_name}",
          host: host,
          type: 'http',
          encryption: true,
          integrationids: [ENV['PINGDOM_ALERT_INTEGRATION_ID']], # integrates with slack
          port: 443,
          probe_filters: ['region:EU'],
          resolution: 1,
          sendnotificationwhendown: 6,
          tags: [service_name],
          url: '/health'
        }
      end
    end
  end
end
