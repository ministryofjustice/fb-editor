class NewFlowPageGenerator
  def initialize(page_uuid:, latest_metadata:, default_next: nil)
    @page_uuid = page_uuid
    @default_next = default_next
    @latest_metadata = latest_metadata
  end

  def to_metadata
    { page_uuid => flow_page_metadata }
  end

  private

  attr_reader :page_uuid, :default_next, :latest_metadata

  def flow_page_metadata
    flow_page = default_metadata
    flow_page['next']['default'] = default_next.to_s
    flow_page
  end

  def default_metadata
    DefaultMetadata['flow.page']
  end
end
