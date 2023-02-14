class Traversable
  attr_reader :service, :flow_uuid

  def initialize(service:, flow_uuid:)
    @service = service
    @flow_uuid = flow_uuid
    @page_uuids = []
    @routes = []
  end

  def question_pages
    previous_pages.select(&:question_page?)
  end

  private

  def previous_pages
    service.pages.reject do |page|
      next if page.uuid == flow_uuid

      following_pages_uuids.include?(page.uuid)
    end
  end

  def following_pages_uuids
    @following_pages_uuids ||= begin
      @routes.push(
        MetadataPresenter::Route.new(service:, traverse_from: flow_uuid)
      )
      until @routes.empty?
        route = @routes.shift
        @page_uuids |= page_uuids_only(route.traverse)
        @routes |= route.routes
      end

      @page_uuids
    end
  end

  def page_uuids_only(uuids)
    uuids.reject { |uuid| service.flow_object(uuid).branch? }
  end
end
