module MetadataApiClient
  class Service < Resource
    def self.all_services(page:, per_page:, name_query: '')
      response = connection.get(
        '/services',
        {
          page:,
          per_page:,
          name_query:
        }
      ).body

      {
        total_services: response['total_services'],
        services: Array(response['services']).map { |service| new(service) }
      }
    end

    def self.all(user_id:)
      response = connection.get("/services/users/#{user_id}").body['services']
      Array(response).map { |service| new(service) }
    end

    def self.latest_version(service_id)
      new(
        connection.get("/services/#{service_id}/versions/latest").body
      ).metadata
    end

    def self.create(payload)
      response = connection.post('/services', payload)
      new(response.body)
    rescue Faraday::UnprocessableEntityError => e
      error_messages(e)
    end

    def self.delete(service_id)
      connection.delete(ActionController::Base.helpers.sanitize("/services/#{service_id}"))
    rescue Faraday::BadRequestError => e
      error_messages(e)
    end
  end
end
