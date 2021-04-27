class PageUpdater
  include MetadataFinder
  attr_reader :latest_metadata, :id, :service_id, :actions, :attributes

  def initialize(attributes)
    @latest_metadata = attributes.delete(:latest_metadata).to_h.deep_dup
    @id = attributes.delete(:id)
    @service_id = attributes.delete(:service_id)
    @actions = attributes.delete(:actions)
    @attributes = attributes
  end

  def update
    version = MetadataApiClient::Version.create(
      service_id: service_id,
      payload: metadata
    )

    return version.metadata unless version.errors?

    false
  end

  def component_added
    MetadataPresenter::Component.new(@component_added) if @component_added
  end

  def metadata
    object = find_node_attribute_by_id
    page_collection, index = find_page_collection_and_index(object)

    new_object = object.merge(attributes)

    if @actions && @actions[:add_component].present?
      new_object[component_collection] ||= []

      component = new_component(new_object)
      new_object[component_collection].push(component)
      @component_added = component
    end

    @latest_metadata[page_collection][index] = new_object
    @latest_metadata
  end

  def component_collection
    @component_collection ||= @actions[:component_collection]
  end

  def new_component(new_object)
    NewComponentGenerator.new(
      component_type: @actions[:add_component],
      page_url: new_object['url'].gsub(/^\//, ''),
      components: all_components(new_object)
    ).to_metadata
  end

  def all_components(obj)
    [obj['components'], obj['extra_components']].flatten.compact
  end
end
