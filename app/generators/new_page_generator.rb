class NewPageGenerator
  include ActiveModel::Model
  include ApplicationHelper
  attr_accessor :page_type,
                :page_url,
                :component_type,
                :latest_metadata,
                :add_page_after,
                :page_uuid

  STANDALONE = 'standalone'.freeze

  def to_metadata
    return page_metadata if latest_metadata.blank?

    standalone_page? ? add_standalone_page : add_flow_page
  end

  def page_metadata
    @page_metadata ||= begin
      metadata = DefaultMetadata["page.#{page_type}"]

      metadata.tap do
        metadata['_id'] = page_name
        metadata['_uuid'] = page_uuid
        metadata['url'] = page_url
        if component_type.present?
          metadata['components'].push(component)
        end
      end
    end
  end

  private

  def standalone_page?
    page_type == STANDALONE
  end

  def add_flow_page
    latest_metadata.tap do
      latest_metadata['flow'][previous_page_uuid]['next']['default'] = page_metadata['_uuid']
      latest_metadata['flow'].merge!(new_flow_page_metadata)
      latest_metadata['pages'].insert(pages_index, page_metadata)
    end
  end

  def new_flow_page_metadata
    NewFlowPageGenerator.new(
      page_uuid: page_metadata['_uuid'],
      page_index: index_to_be_inserted_after,
      latest_metadata: latest_metadata
    ).to_metadata
  end

  def add_standalone_page
    latest_metadata.tap do
      latest_metadata['standalone_pages'].push(page_metadata)
    end
  end

  def page_name
    @page_name ||= "page.#{strip_url(page_url)}"
  end

  def component
    NewComponentGenerator.new(
      component_type: component_type,
      page_url: page_url
    ).to_metadata
  end

  INSERT_LAST = -1

  def pages_index
    @pages_index ||= begin
      if add_page_after.present?
        index = index_to_be_inserted_after

        return index + 1 if index
      end

      INSERT_LAST
    end
  end

  def index_to_be_inserted_after
    @index_to_be_inserted_after ||=
      latest_metadata['pages'].index(page_to_be_inserted_after)
  end

  def page_to_be_inserted_after
    @page_to_be_inserted_after ||=
      latest_metadata['pages'].find { |page| page['_uuid'] == add_page_after }
  end

  def previous_page_uuid
    if pages_index == INSERT_LAST
      latest_metadata['pages'].last['_uuid']
    else
      page_to_be_inserted_after['_uuid']
    end
  end
end
