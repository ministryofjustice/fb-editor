module Api
  class UndoController < ApiController
    def previous
      response = MetadataApiClient::Version.previous(service.service_id)
      return head :bad_request if response.errors?

      new_version = MetadataApiClient::Version.create(service_id: service.service_id, payload: response.metadata)
      return head :bad_request if new_version.errors?

      redirect_to edit_service_path(service.service_id)
    end
  end
end
