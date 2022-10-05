module Api
  class UndoController < ApiController
    def previous
      response = MetadataApiClient::Version.previous(service.service_id)
      return head :bad_request if response.errors?

      new_version = MetadataApiClient::Version.create(service_id: service.service_id, payload: response.metadata)
      return head :bad_request if new_version.errors?

      undo_redo
      redirect_to edit_service_path(service.service_id)
    end

    def undo_redo
      if session[:undo]
        if session[:undo][:text] == t('actions.undo_redo.undo_move')
          session[:undo] = {
            action: 'redo',
            text: t('actions.undo_redo.redo_move')
          }
        elsif session[:undo][:text] == t('actions.undo_redo.undo_change_next_page')
          session[:undo] = {
            action: 'redo',
            text: t('actions.undo_redo.redo_change_next_page')
          }
        elsif session[:undo][:text] == t('actions.undo_redo.redo_move')
          session[:undo] = {
            action: 'undo',
            text: t('actions.undo_redo.undo_move')
          }
        elsif session[:undo][:text] == t('actions.undo_redo.redo_change_next_page')
          session[:undo] = {
            action: 'undo',
            text: t('actions.undo_redo.redo_change_next_page')
          }
        end
      end
    end
  end
end
