class Detached
  def initialize(service:, ordered_flow:, exclude_branches: false)
    @service = service
    @ordered_flow = ordered_flow
    @exclude_branches = exclude_branches
  end

  def flow_objects
    detached_uuids.map { |uuid| service.flow_object(uuid) }
  end

  private

  attr_reader :service, :ordered_flow, :exclude_branches

  def detached_uuids
    (service.flow.keys - ordered_flow.map(&:uuid).uniq).reject do |uuid|
      service.flow_object(uuid).branch? && exclude_branches
    end
  end
end
