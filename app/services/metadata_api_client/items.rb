module MetadataApiClient
  class Items < Resource
    def self.create(service_id:, component_id:, created_by:, data:)
      response = connection.post(
        "/services/#{service_id}/components/#{component_id}/items/all",
        {
          service_id:,
          component_id:,
          created_by:,
          data:
        }
      )
      new(response.body)
    rescue Faraday::UnprocessableEntityError => e
      error_messages(e)
    end

    def self.all(service_id:)
      response = connection.get(
        "/services/#{service_id}/items/all"
      )
      new(response.body)
    rescue Faraday::UnprocessableEntityError => e
      error_messages(e)
    end

    def self.find(service_id:, component_id:)
      response = connection.get(
        "/services/#{service_id}/components/#{component_id}/items"
      )
      new(response.body)
    rescue Faraday::UnprocessableEntityError => e
      error_messages(e)
    rescue Faraday::ResourceNotFound => e
      error_messages(e, send_sentry: false)
    end
  end
end
