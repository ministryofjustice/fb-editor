class AutocompleteItemsPresenter
  include ActionView::Helpers
  include GovukLinkHelper
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
    env = ENV['RAILS_ENV'] == 'development' ? 'dev' : ENV['RAILS_ENV']
    pages_with_autocomplete_component.each_with_object([]) do |page, arry|
      page.components.each do |component|
        next unless component.uuid.in?(component_uuids_without_items)

        link = govuk_link_to(component.humanised_title, Rails.application.routes.url_helpers.edit_page_path(service.service_id, page.uuid))

        description = I18n.t("publish.autocomplete_items.#{env}.message", title: link)

        msg = description.html_safe
        arry.push(msg)
      end
    end
  end

  def message
    # because submission warnings presenter expect presenter to have methods message
    messages
  end
end
