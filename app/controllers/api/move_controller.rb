module Api
  class MoveController < BranchesController
    def targets
      @move = Move.new(base_params)
      render :new, layout: false
    end

    def change
      @move = Move.new(base_params.merge(change_params))
      @move.change
      redirect_to edit_service_path(service.service_id)
    end

    private

    def base_params
      {
        service: service,
        grid: grid,
        previous_flow_uuid: params[:previous_flow_uuid],
        to_move_uuid: params[:flow_uuid]
      }
    end

    def change_params
      {
        target_uuid: params[:target_uuid] || params[:move][:target_uuid],
        previous_flow_uuid: params[:move][:previous_flow_uid],
        branch_uuid: params[:move][:branch_uuid],
        conditional_uuid: params[:move][:conditional_uuid]
      }
    end
  end
end
