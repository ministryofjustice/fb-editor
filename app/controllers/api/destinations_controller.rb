module Api
  class DestinationsController < BranchesController
    def new
      @destination = destination

      render :new, layout: false
    end

    def create
      destination.change
      UndoPresenter.undo_session_data('undo', 'change_next_page')

      redirect_to edit_service_path(service.service_id)
    end

    private

    # rubocop:disable Naming/MemoizedInstanceVariableName
    def destination
      @_destination ||= Destination.new(
        service: service,
        flow_uuid: params[:flow_uuid],
        destination_uuid: params[:destination_uuid]
      )
    end
    # rubocop:enable Naming/MemoizedInstanceVariableName
  end
end
