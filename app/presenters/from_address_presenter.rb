class FromAddressPresenter
  include ActionView::Helpers
  include GovukLinkHelper

  def initialize(from_address, messages, service_id)
    @from_address = from_address
    @service_id = service_id
    @messages = messages
  end

  def message
    key = from_address.status&.to_sym || :default
    messages[key].gsub('%{href}', link).html_safe
  end

  private

  attr_reader :from_address, :service_id, :messages

  def link
    govuk_link_to(
      I18n.t('warnings.from_address.publishing.link'),
      Rails.application.routes.url_helpers.settings_from_address_index_path(service_id)
    )
  end
end
