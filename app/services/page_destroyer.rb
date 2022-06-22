class PageDestroyer
  include MetadataFinder
  attr_reader :latest_metadata, :uuid, :service_id, :attributes

  def initialize(attributes)
    @latest_metadata = attributes.delete(:latest_metadata).to_h.deep_dup
    @uuid = attributes.delete(:uuid)
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
    object = find_node_attribute_by_uuid
    page_collection, index = find_page_collection_and_index(object)

    # Don't delete start pages
    return @latest_metadata if object['_type'] == 'page.start'

    @latest_metadata[page_collection].delete_at(index)
    @latest_metadata['flow'] = update_service_flow if page_collection == 'pages'
    @latest_metadata
  end

  private

  def update_service_flow
    linked_to_uuid = @latest_metadata['flow'][uuid]['next']['default']

    @latest_metadata['flow'].each do |_flow_uuid, properties|
      if properties['next']['default'] == uuid
        properties['next']['default'] = uuid == linked_to_uuid ? '' : linked_to_uuid
      end

      next if properties['next']['conditionals'].blank?

      properties['next']['conditionals'].each do |conditional|
        if conditional['next'] == uuid
          conditional['next'] = linked_to_uuid
        end
      end
    end

    @latest_metadata['flow'].delete(uuid)
    @latest_metadata['flow']
  end
end
