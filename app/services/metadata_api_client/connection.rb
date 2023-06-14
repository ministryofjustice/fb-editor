module MetadataApiClient
  class Connection
    SUBSCRIPTION = 'metadata_api.client'
    OPEN_TIMEOUT = 60
    TIMEOUT = 60

    attr_reader :connection

    delegate :get, :post, :put, :delete, to: :connection

    def initialize(root_url: ENV['METADATA_API_URL'])
      @connection = Faraday.new(root_url) do |conn|
        conn.request :json
        conn.response :json
        conn.response :raise_error
        conn.use :instrumentation, name: SUBSCRIPTION
        conn.options[:open_timeout] = OPEN_TIMEOUT
        conn.options[:timeout] = TIMEOUT

        conn.request :authorization, 'Bearer', service_access_token
      end
    end

    def service_access_token
      @service_access_token ||= Fb::Jwt::Auth::ServiceAccessToken.new.generate
    end
  end
end
