module Api
  class MoveController < ApiController
    def targets
      @move = Move.new(base_params)
      render @move, layout: false
    end

    def change
      @move = Move.new(base_params.merge(change_params))
      @move.change

      if @move.valid?
        session[:undo] = {
          action: 'undo',
          undoable_action: 'move',
          text: t('actions.undo_redo.undo_move')
        }
      end
      # TODO: do we want to add here in this path toos
      redirect_to edit_service_path(service.service_id)
    end

    private

    def base_params
      {
        service: service,
        grid: grid,
        previous_flow_uuid: params[:previous_flow_uuid],
        previous_conditional_uuid: params[:previous_conditional_uuid],
        to_move_uuid: params[:flow_uuid]
      }
    end

    def change_params
      params.require(:move).permit(
        :previous_flow_uuid,
        :previous_conditional_uuid,
        :target_uuid,
        :target_conditional_uuid
      )
    end
  end
end
