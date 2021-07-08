class NewFlowPageGenerator
  def initialize(page_uuid:, page_index:, latest_metadata:)
    @page_uuid = page_uuid
    @page_index = page_index
    @latest_metadata = latest_metadata
  end

  def to_metadata
    { page_uuid => flow_page_metadata }
  end

  private

  attr_reader :page_uuid, :page_index, :latest_metadata

  def flow_page_metadata
    flow_page = default_metadata
    flow_page['next']['default'] = default_next
    flow_page
  end

  def default_next
    next_page.present? ? next_page['_uuid'] : ''
  end

  def next_page
    @next_page ||= begin
      return if page_index.nil?

      latest_metadata['pages'][page_index + 1]
    end
  end

  def default_metadata
    DefaultMetadata['flow.page']
  end
end
