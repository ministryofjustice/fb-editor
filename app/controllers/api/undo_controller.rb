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
      if response.errors?
        render json: { action: params[:action] }, status: :bad_request and return
      end

      new_version = MetadataApiClient::Version.create(service_id: service.service_id, payload: response.metadata)
      if new_version.errors?
        render json: { action: params[:action] }, status: :bad_request and return
      end

      session[:undo] = UndoPresenter.toggle(session[:undo][:action], session[:undo][:undoable_action]) if session[:undo]
      if request.xhr?
        render json: { redirect: edit_service_path(service.service_id).to_s }
      else
        redirect_to edit_service_path(service.service_id)
      end
    end
  end
end
