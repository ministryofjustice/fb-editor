class Uptime
  module Adapters
    class Pingdom
      API_URL = 'https://api.pingdom.com/api/3.1'.freeze
      CHECKS = 'checks'.freeze
      FORM_BUILDER = 'Form Builder'.freeze
      SUBSCRIPTION = 'uptime.pingdom'.freeze
      TIMEOUT = 10

      attr_reader :connection

      delegate :get, :post, :put, :delete, to: :connection

      def initialize(root_url: API_URL)
        @connection = Faraday.new(root_url) do |conn|
          conn.options[:open_timeout] = TIMEOUT
          conn.options[:timeout] = TIMEOUT
          conn.request :instrumentation, name: SUBSCRIPTION
          conn.request(:authorization, 'Bearer', ENV['PINGDOM_TOKEN'])
          conn.request :json
          conn.response :raise_error
          conn.response :json
        end
      end

      def checks
        response = get("#{CHECKS}?include_tags=true")
        response.body['checks'].select do |check|
          check['name'].include?(FORM_BUILDER)
        end
      end

      def create(service_name, host, service_id)
        response = post(CHECKS, creation_payload(service_name, host, service_id))
        response.body['check']['id']
      rescue Faraday::BadRequestError
        # Pingdom will sometimes return a 400 even though it actually creates
        # the check :(
        # In those instances look for it via the service id saved to the tags
        response = find_check(service_id)
        return response['id'] if response.present?

        Sentry.capture_message(
          "Unable to create Uptime Check for service #{service_id}"
        )
      end

      def update(id, service_name, host)
        put("#{CHECKS}/#{id}", updating_payload(service_name, host))
      rescue Faraday::BadRequestError
        Sentry.capture_message(
          "Unable to update Uptime Check for service #{service_id}"
        )
      end

      def destroy(id)
        delete("#{CHECKS}/#{id}")
      end

      def exists?(service_id)
        find_check(service_id).present?
      end

      def find_check(service_id)
        checks.find do |check|
          check['tags'].find do |tag|
            tag['name'].include?(service_id)
          end
        end
      end

      private

      def creation_payload(service_name, host, service_id)
        {
          name: "#{FORM_BUILDER} - #{service_name}",
          host:,
          type: 'http',
          encryption: true,
          integrationids: [ENV['PINGDOM_ALERT_INTEGRATION_ID']], # integrates with slack
          port: 443,
          probe_filters: ['region:EU'],
          resolution: 1,
          sendnotificationwhendown: 6,
          tags: [service_id],
          url: '/health'
        }
      end

      def updating_payload(service_name, host)
        {
          name: "#{FORM_BUILDER} - #{service_name}",
          host:
        }
      end
    end
  end
end
