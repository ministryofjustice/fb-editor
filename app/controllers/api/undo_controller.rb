module Api
  class UndoController < ApiController
    def undo
      case params[:undoable_action]
      when 'change_next_page'
        session[:undo] = {
          action: 'undo',
          undoable_action: 'change_next_page',
          text: t('actions.undo_redo.undo_change_next_page')
        }
      when 'move'
        session[:undo] = {
          action: 'undo',
          undoable_action: 'move',
          text: t('actions.undo_redo.undo_move')
        }
      end
      call_previous_version
    end

    def redo
      case params[:undoable_action]
      when 'move'
        session[:undo] = {
          action: 'redo',
          undoable_action: 'move',
          text: t('actions.undo_redo.redo_move')
        }
      when 'change_next_page'
        session[:undo] = {
          action: 'redo',
          undoable_action: 'change_next_page',
          text: t('actions.undo_redo.redo_change_next_page')
        }
      end
      call_previous_version
    end

    def call_previous_version
      response = MetadataApiClient::Version.previous(service.service_id)
      return head :bad_request if response.errors?

      new_version = MetadataApiClient::Version.create(service_id: service.service_id, payload: response.metadata)
      return head :bad_request if new_version.errors?

      undo_redo if session[:undo]
      redirect_to edit_service_path(service.service_id)
    end

    def undo_redo
      if session[:undo][:text] == t('actions.undo_redo.undo_move')
        session[:undo] = {
          action: 'redo',
          undoable_action: 'move',
          text: t('actions.undo_redo.redo_move')
        }
      elsif session[:undo][:text] == t('actions.undo_redo.undo_change_next_page')
        session[:undo] = {
          action: 'redo',
          undoable_action: 'change_next_page',
          text: t('actions.undo_redo.redo_change_next_page')
        }
      elsif session[:undo][:text] == t('actions.undo_redo.redo_move')
        session[:undo] = {
          action: 'undo',
          undoable_action: 'move',
          text: t('actions.undo_redo.undo_move')
        }
      elsif session[:undo][:text] == t('actions.undo_redo.redo_change_next_page')
        session[:undo] = {
          action: 'undo',
          undoable_action: 'change_next_page',
          text: t('actions.undo_redo.undo_change_next_page')
        }
      end
    end
  end
end
