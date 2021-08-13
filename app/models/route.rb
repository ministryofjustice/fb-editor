class Route
  attr_reader :service, :traverse_from
  attr_accessor :page_uuids, :routes

  def initialize(service:, traverse_from:)
    @service = service
    @traverse_from = traverse_from
    @routes = []
    @page_uuids = []
  end

  def traverse
    @flow_uuid = traverse_from

    until @flow_uuid.blank?
      flow_object = service.flow_object(@flow_uuid)

      if flow_object.branch?
        destination_uuids(flow_object).each do |uuid|
          @routes.push(Route.new(service: service, traverse_from: uuid))
        end
        break
      else
        @page_uuids.push(@flow_uuid) unless @page_uuids.include?(@flow_uuid)
        @flow_uuid = flow_object.default_next
      end
    end
  end

  private

  def destination_uuids(flow_object)
    flow_object.conditionals.map(&:next).push(flow_object.default_next)
  end
end
