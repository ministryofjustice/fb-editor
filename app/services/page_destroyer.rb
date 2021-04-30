class PageDestroyer
  include MetadataFinder
  attr_reader :latest_metadata, :id, :service_id, :attributes

  def initialize(attributes)
    @latest_metadata = attributes.delete(:latest_metadata).to_h.deep_dup
    @id = attributes.delete(:id)
    @service_id = attributes.delete(:service_id)
    @attributes = attributes
  end

  def destroy
    version = MetadataApiClient::Version.create(
      service_id: service_id,
      payload: metadata
    )

    version.metadata
  end

  def metadata
    object = find_node_attribute_by_id
    page_collection, index = find_page_collection_and_index(object)

    # Don't delete start pages
    return @latest_metadata if object['_type'] == 'page.start'

    @latest_metadata[page_collection].delete_at(index)
    @latest_metadata['pages'][0]['steps'].delete(@id) if flow_page?(page_collection)
    @latest_metadata
  end
end
