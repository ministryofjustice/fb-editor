class PageUpdater
  include MetadataFinder
  attr_reader :latest_metadata, :uuid, :service_id, :actions, :attributes

  def initialize(attributes)
    @latest_metadata = attributes.delete(:latest_metadata).to_h.deep_dup
    @uuid = attributes.delete(:uuid)
    @service_id = attributes.delete(:service_id)
    @actions = attributes.delete(:actions)
    @attributes = attributes
  end

  def update
    version = MetadataApiClient::Version.create(
      service_id:,
      payload: metadata
    )

    return version.metadata unless version.errors?

    false
  end

  def component_added
    MetadataPresenter::Component.new(@component_added) if @component_added
  end

  def metadata
    object = find_node_attribute_by_uuid
    page_collection, index = find_page_collection_and_index(object)

    new_object = object.merge(attributes)

    if @actions && @actions[:add_component].present?
      new_object[component_collection] ||= []

      component = new_component(new_object)
      new_object[component_collection].push(component)
      @component_added = component
    end

    if @actions && @actions[:delete_components].present?
      %w[components extra_components].each do |component_type|
        next if new_object[component_type].blank?

        new_object[component_type].delete_if do |hash|
          hash['_uuid'].in?(@actions[:delete_components])
        end
      end
    end
    new_object = check_item_uuids(new_object)
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

  # When the frontend sends new options it uses the component UUID to the
  # option uuid so we need to do this.
  #
  def check_item_uuids(new_object)
    object =
      ActiveSupport::HashWithIndifferentAccess.new(new_object)

    Array(object[:components]).map do |component|
      component_id = component[:_uuid]

      Array(component[:items]).each do |item|
        if item[:_uuid] == component_id || item[:_uuid].blank?
          item[:_uuid] = SecureRandom.uuid
        end
      end
    end

    object
  end
end
