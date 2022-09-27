module Api
  class UndoController < ApiController
    def previous
      response = MetadataApiClient::Version.previous(service.service_id)
      MetadataApiClient::Version.create(service_id: service.service_id, payload: response.metadata)
      redirect_to edit_service_path(service.service_id)
    end
  end
end
