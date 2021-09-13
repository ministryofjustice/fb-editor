module Api
  class DestinationsController < BranchesController
    def new
      @destination = build_destination

      render :new, layout: false
    end

    def create
      destination = build_destination

      destination.change
      redirect_to edit_service_path(service.service_id)
    end

    private

    def build_destination
      Destination.new(
        flow_uuid: params[:flow_uuid],
        destination_uuid: params[:destination_uuid]
      )
    end
  end
end
