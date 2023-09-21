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
    ordered_grids.each_with_object([]) do |grid, flows|
      flows.push(grid.build) unless traversed.include?(grid.start_from)
      traversed |= grid.flow_uuids
    end
  end

  def ordered
    all_obj = detached_flows.flatten
    all_obj.select { |obj| obj.is_a?(MetadataPresenter::Flow) }
  end

  def ordered_no_branches
    ordered.select { |obj| obj.type == 'flow.page' }
  end

  private

  attr_reader :service, :main_flow_uuids, :exclude_branches

  def detached_uuids
    (service.flow.keys - main_flow_uuids).reject do |uuid|
      service.flow_object(uuid).branch? && exclude_branches
    end
  end

  def ordered_grids
    grids = detached_grids.sort_by do |grid|
      grid.build
      grid.flow_uuids.count
    end
    grids.reverse
  end

  def detached_grids
    detached_uuids.map do |uuid|
      MetadataPresenter::Grid.new(
        service,
        start_from: uuid,
        main_flow: main_flow_uuids,
        traverse_cap: 1000
      )
    end
  end
end
