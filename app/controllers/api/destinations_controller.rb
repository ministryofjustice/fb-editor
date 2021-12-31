module Api
  class DestinationsController < BranchesController
    def new
      @destination = destination

      render :new, layout: false
    end

    def create
      destination.metadata

      if destination.cya_and_confirmation_present? || destination_change_confirmed?
        destination.change
        redirect_to edit_service_path(service.service_id)
      else
        redirect_to edit_service_path(service.service_id, flow_uuid: params[:flow_uuid], destination_uuid: params[:destination_uuid])
      end
    end

    def destination_change_confirmed?
      (destination.checkanswers_detached? || destination.confirmation_detached?) &&
        params[:user_confirmation].present?
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
