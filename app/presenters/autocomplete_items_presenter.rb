class AutocompleteItemsPresenter
  attr_reader :autocomplete_items, :service

  def initialize(service, autocomplete_items)
    @service = service
    @autocomplete_items = autocomplete_items
  end

  def autocomplete_component_uuids
    pages_with_autocomplete_component.map { |page|
      page.components.map(&:uuid)
    }.flatten
  end

  def component_uuids_without_items
    autocomplete_component_uuids - autocomplete_items.metadata['items'].keys
  end

  def pages_with_autocomplete_component
    service.pages.select do |page|
      page.components.any?(&:autocomplete?)
    end
  end

  def messages
    @messages ||=
      pages_with_autocomplete_component.each_with_object([]) do |page, arry|
        page.components.each do |component|
          next unless component.uuid.in?(component_uuids_without_items)

          arry.push(
            { component_title: component.humanised_title, page_uuid: page.uuid }
          )
        end
      end
  end
end
