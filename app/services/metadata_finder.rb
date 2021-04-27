# The included object needs to respond to #id, #latest_metadata
#
module MetadataFinder
  def find_node_attribute_by_id
    latest_metadata.extend Hashie::Extensions::DeepLocate

    latest_metadata.deep_locate(find_id).first
  end

  def find_id
    lambda do |key, value, _object|
      key == '_id' && value == id
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
