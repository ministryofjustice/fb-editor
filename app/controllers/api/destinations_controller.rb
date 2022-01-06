module Api
  class DestinationsController < BranchesController
    def new
      @destination = destination

      render :new, layout: false
    end

    def create
      if page_disconnection_warning.show_warning? && params[:user_confirmation].blank?
        redirect_to edit_service_path(
          service.service_id,
          flow_uuid: params[:flow_uuid],
          destination_uuid: params[:destination_uuid]
        )
      else
        destination.change
        redirect_to edit_service_path(service.service_id)
      end
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

    def page_disconnection_warning
      PageDisconnectionWarning.new(
        current_grid: current_grid,
        potential_grid: potential_grid
      )
    end

    def current_grid
      grid = MetadataPresenter::Grid.new(service)
      grid.build
      grid
    end

    def potential_grid
      grid = MetadataPresenter::Grid.new(
        MetadataPresenter::Service.new(destination.metadata)
      )
      grid.build
      grid
    end
  end
end
