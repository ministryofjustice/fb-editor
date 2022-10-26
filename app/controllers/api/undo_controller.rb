module Api
  class UndoController < ApiController
    def undo
      store_session
      call_previous_version
    end

    def redo
      store_session
      call_previous_version
    end

    def store_session
      session[:undo] = UndoPresenter.undo_session_data(params[:action], params[:undoable_action])
    end

    def call_previous_version
      response = MetadataApiClient::Version.previous(service.service_id)
      return head :bad_request if response.errors?

      new_version = MetadataApiClient::Version.create(service_id: service.service_id, payload: response.metadata)
      return head :bad_request if new_version.errors?

      session[:undo] = UndoPresenter.toggle(session[:undo][:action], session[:undo][:undoable_action]) if session[:undo]

      redirect_to edit_service_path(service.service_id)
    end
  end
end
