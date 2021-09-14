class OrderedFlow
  def initialize(**args)
    @service = args.fetch(:service)
    @exclude_branches = args.fetch(:exclude_branches, false)
    @pages_flow = args.fetch(:pages_flow, false)
    @ordered = []
  end

  def build
    previous_uuid = ''
    next_uuid = service.start_page.uuid

    service.flow.size.times do
      # confirmation page, and in the future exit pages
      next if next_uuid.empty?

      flow_object = service.flow_object(next_uuid)
      add_flow_object(service.flow_object(previous_uuid), flow_object)

      if flow_object.branch?
        flow_object.conditionals.each do |conditional|
          next_object = service.flow_object(conditional.next)
          add_flow_object(flow_object, next_object)
        end
      end

      previous_uuid = flow_object.uuid
      next_uuid = flow_object.default_next
    end

    @ordered
  end

  private

  attr_accessor :service, :exclude_branches, :pages_flow, :ordered

  def add_flow_object(previous, current)
    if pages_flow
      @ordered.append(
        FlowStack.new(
          service: service,
          previous: previous,
          current: current
        )
      )
    else
      @ordered.append(current)
    end
  end
end
