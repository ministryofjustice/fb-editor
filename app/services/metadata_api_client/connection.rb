module MetadataApiClient
  class Connection
    SUBSCRIPTION = 'metadata_api.client'
    DEFAULT_OPEN_TIMEOUT = 10
    DEFAULT_READ_TIMEOUT = 60

    attr_reader :connection

    delegate :get, :post, :put, :delete, to: :connection

    def initialize(root_url: ENV['METADATA_API_URL'])
      @connection = Faraday.new(root_url, headers:) do |conn|
        conn.request :json
        conn.response :json
        conn.response :raise_error
        conn.use :instrumentation, name: SUBSCRIPTION

        # Number of seconds to wait for the connection to open
        conn.options.open_timeout = DEFAULT_OPEN_TIMEOUT

        # Number of seconds to wait for one block to be read
        conn.options.read_timeout = DEFAULT_READ_TIMEOUT

        conn.request :authorization, 'Bearer', service_access_token
      end
    end

    private

    def headers
      {
        'User-Agent' => 'Editor',
        'X-Request-Id' => Current.request_id
      }.freeze
    end

    def service_access_token
      @service_access_token ||= Fb::Jwt::Auth::ServiceAccessToken.new.generate
    end
  end
end
