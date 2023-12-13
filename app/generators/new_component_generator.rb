class NewComponentGenerator
  include ApplicationHelper
  attr_reader :component_type, :page_url, :components

  def initialize(component_type:, page_url:, components: [])
    @component_type = component_type
    @page_url = page_url
    @components = components
  end

  def to_metadata
    metadata = DefaultMetadata["component.#{component_type}"]

    metadata.tap do
      metadata['_uuid'] = SecureRandom.uuid
      metadata['_id'] = component_id
      metadata['name'] = component_id

      if metadata['items'].present?
        metadata['items'].each_with_index do |item, index|
          item['_id'] = "#{component_id}_item_#{index + 1}"
          item['_uuid'] = SecureRandom.uuid
        end
      end
    end
  end

  private

  def component_id
    @component_id ||= "#{strip_url(page_url)}_#{component_type}_#{increment}"
  end

  def increment
    components = components_of_type(component_type)
    if components.empty?
      1
    else
      max_component_index(components) + 1
    end
  end

  def components_of_type(type)
    components.select { |c| c['_type'] == type }
  end

  def max_component_index(components)
    components.map { |c| component_index(c) }.max
  end

  def component_index(component)
    component['_id'].split('_').last.to_i
  end
end
