class FlowStack
  def initialize(service:, previous:, current:)
    @service = service
    @previous = previous
    @current = current
  end

  def grouped_flow_objects
    previous.branch? ? grouped_by_next : [[current]]
  end

  private

  attr_reader :service, :previous, :current

  def grouped_by_next
    # assumes that destinations from a branch are always pages
    # once we support stacking branches this will need to be expanded
    next_flow_objects.group_by(&:default_next).values
  end

  def next_flow_objects
    previous.conditionals.map { |conditional|
      service.flow_object(conditional.next)
    }.push(service.flow_object(previous.default_next))
  end
end
