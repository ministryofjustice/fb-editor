class AutocompleteItemsPresenter
  include ActionView::Helpers
  include GovukLinkHelper
  attr_reader :autocomplete_items, :grid, :deployment_environment

  def initialize(grid, autocomplete_items, deployment_environment)
    @grid = grid
    @autocomplete_items = autocomplete_items
    @deployment_environment = deployment_environment
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
    @pages_with_autocomplete_component ||=
      pages_in_main_flow.select { |page| page._id == 'page.autocomplete' }
  end

  def messages
    @messages ||=
      pages_with_autocomplete_component.each_with_object([]) do |page, arry|
        page.components.each do |component|
          next unless component.uuid.in?(component_uuids_without_items)

          msg = I18n.t("publish.autocomplete_items.#{deployment_environment}.message", title: link(component, page)).html_safe
          arry.push(msg)
        end
      end
  end

  alias_method :message, :messages

  private

  def link(component, page)
    govuk_link_to(
      component.humanised_title,
      Rails.application.routes.url_helpers.edit_page_path(
        grid.service.service_id,
        page.uuid
      )
    )
  end

  def pages_in_main_flow
    main_flow_uuids = grid.page_uuids
    @pages_in_main_flow ||= grid.service.pages.select { |page| page.uuid.in?(main_flow_uuids) }
  end
end
