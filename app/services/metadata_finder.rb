# The included object needs to respond to #id, #latest_metadata
#
module MetadataFinder
  def find_node_attribute_by_uuid
    latest_metadata.extend Hashie::Extensions::DeepLocate

    latest_metadata.deep_locate(find_uuid).first
  end

  def find_uuid
    lambda do |key, value, _object|
      key == '_uuid' && value == uuid
    end
  end

  def find_page_collection_and_index(object)
    %w[pages standalone_pages].each do |collection|
      index = latest_metadata[collection].index(object)
      return collection, index if index.present?
    end
  end

  PAGES = 'pages'.freeze

  def flow_page?(page_collection)
    page_collection == PAGES
  end
end
