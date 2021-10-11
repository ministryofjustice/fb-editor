class Detached
  def initialize(service:, main_flow_uuids:, exclude_branches: false)
    @service = service
    @main_flow_uuids = main_flow_uuids
    @exclude_branches = exclude_branches
  end

  def flow_objects
    detached_uuids.map { |uuid| service.flow_object(uuid) }
  end

  def detached_flows
    traversed = []

    detached_uuids.each_with_object([]) do |uuid, flows|
      grid = MetadataPresenter::Grid.new(
        service,
        start_from: uuid,
        main_flow: main_flow_uuids
      )
      flows.push(grid.build) unless traversed.include?(grid.start_from)
      traversed |= grid.flow_uuids
    end
  end

  private

  attr_reader :service, :main_flow_uuids, :exclude_branches

  def detached_uuids
    (service.flow.keys - main_flow_uuids).reject do |uuid|
      service.flow_object(uuid).branch? && exclude_branches
    end
  end
end
