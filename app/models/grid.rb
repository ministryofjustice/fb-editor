class Grid
  def initialize(service)
    @service = service
    @ordered = []
    @routes = []
    @traversed = []
  end

  def build
    @ordered = row_zero
    @routes = route_from_start.routes
    @traversed = route_from_start.flow_uuids

    index = 0
    until @routes.empty?
      if index > total_potential_routes
        Sentry.capture_message('Exceeded total number of potential routes')
        break
      end

      route = @routes.shift
      traversed_uuids = route.traverse
      insert_into_flow(traversed_uuids, route.column)
      @routes |= route.routes
      @traversed |= traversed_uuids

      index += 1
    end

    @ordered
  end

  def ordered_flow
    @ordered.empty? ? build.flatten : @ordered.flatten
  end

  def ordered_pages
    ordered_flow.reject(&:branch?)
  end

  private

  attr_reader :service
  attr_accessor :ordered, :traversed, :routes

  def row_zero
    route_from_start.traverse.map { |uuid| [service.flow_object(uuid)] }
  end

  def route_from_start
    @route_from_start ||=
      Route.new(service: service, traverse_from: service.start_page.uuid)
  end

  def insert_into_flow(uuids, column)
    uuids.each do |uuid|
      next if @traversed.include?(uuid)

      flow_object = service.flow_object(uuid)
      @ordered[column].append(flow_object)
    end
  end

  def total_potential_routes
    # Deliberately not including the default next for each branch as when row
    # zero is created it takes the first available conditional for each branch.
    # The remaining are then used to create route objects. Therefore the total
    # number of remaining routes will be the same as the total of all the branch
    # conditionals.
    # Add 1 additional route as that represents the route_from_start
    @total_potential_routes ||=
      service.branches.sum { |branch| branch.conditionals.size } + 1
  end
end
