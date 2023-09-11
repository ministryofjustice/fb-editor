class ContentVisibilityCreation
  include MetadataVersion
  include ActiveModel::Model
  delegate :title, :previous_flow_uuid, :version, :service, :conditionals,
           :default_next, to: :conditional_content

  attr_accessor :conditional_content, :latest_metadata

  def save
    return false if conditional_content.invalid? || conditional_content.any_errors?

    create_version
  end

  def metadata
    # conditional_content.conditionals.map{|c| c.to_metadata }
    if component_metadata.key('conditionals')
      component_metadata['conditionals'].merge!(conditional_content_metadata)
    else
      component_metadata['conditionals'] = conditional_content_metadata
    end

    latest_metadata
  end

  def page
    service.page_with_component(conditional_content.component_uuid)
  end

  def component_metadata
    latest_metadata['pages'].find { |p| p['_uuid'] == page['_uuid'] }['components'].find { |c| c['_uuid'] == conditional_content.component_uuid }
  end

  def conditional_content_metadata
    conditional_content.conditionals.map(&:to_metadata)
  end
end
