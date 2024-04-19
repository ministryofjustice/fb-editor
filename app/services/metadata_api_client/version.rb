module MetadataApiClient
  class Version < Resource
    def self.create(service_id:, payload:)
      new(
        connection.post(
          "/services/#{service_id}/versions", { metadata: payload }
        ).body
      )
    rescue Faraday::UnprocessableEntityError => e
      error_messages(e)
    end

    def self.all(service_id)
      response = connection.get(
        "/services/#{service_id}/versions"
      )

      Array(response.body['versions']).map { |version| new(version) }
    rescue Faraday::UnprocessableEntityError => e
      error_messages(e)
    end

    def self.find(service_id:, version_id:)
      response = connection.get(
        "/services/#{service_id}/versions/#{version_id}"
      )
      new(response.body)
    rescue Faraday::UnprocessableEntityError => e
      error_messages(e)
    end

    def self.previous(service_id)
      response = connection.get(
        "/services/#{service_id}/versions/previous"
      )
      new(response.body)
    rescue Faraday::ClientError => e
      error_messages(e)
    end

    def version_id
      metadata['version_id']
    end

    def created_at
      metadata['created_at']
    end

    def created_by
      metadata['created_by']
    end
  end
end
