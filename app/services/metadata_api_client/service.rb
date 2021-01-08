module MetadataApiClient
  class Service
    attr_accessor :id, :name

    def initialize(attributes={})
      @id = attributes['service_id']
      @name = attributes['service_name']
    end

    def ==(other_service)
      id == other_service.id
    end

    def self.all(user_id:)
      response = connection.get("/services/users/#{user_id}").body['services']
      Array(response).map { |service| new(service) }
    end

    def self.create(metadata)
      response = connection.post('/services', metadata)
      new(response.body)
    end

    def self.connection
      Connection.new
    end
  end
end
