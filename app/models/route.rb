class Route
  attr_reader :traverse_from
  attr_accessor :flow_uuids, :routes, :column

  def initialize(service:, traverse_from:, column: 0)
    @service = service
    @traverse_from = traverse_from
    @column = column
    @routes = []
    @flow_uuids = []
  end

  def traverse
    @flow_uuid = traverse_from

    index = column
    until @flow_uuid.blank?
      if index > service.flow.size
        Sentry.capture_message('Exceeded total number of flow objects')
        break
      end

      @flow_uuids.push(@flow_uuid) unless @flow_uuids.include?(@flow_uuid)
      flow_object = service.flow_object(@flow_uuid)

      if flow_object.branch?
        destinations = destination_uuids(flow_object)
        @flow_uuid = destinations.shift

        column_number = index + 1 # column after the branching object
        destinations.each do |uuid|
          @routes.push(Route.new(service: service, traverse_from: uuid, column: column_number))
        end
      else
        @flow_uuid = flow_object.default_next
      end

      index += 1
    end

    @flow_uuids
  end

  private

  attr_reader :service

  def destination_uuids(flow_object)
    flow_object.conditionals.map(&:next).push(flow_object.default_next)
  end
end
