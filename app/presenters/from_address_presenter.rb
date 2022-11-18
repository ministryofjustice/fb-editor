class FromAddressPresenter
  include ActionView::Helpers
  include GovukLinkHelper

  def initialize(from_address:, messages:, service_id:)
    @from_address = from_address
    @service_id = service_id
    @messages = messages
  end

  def message
    return unless messages.key?(key)

    messages[key][:text].gsub('%{link}', link).html_safe
  end

  def icon_fallback
    I18n.t('warnings.publish.dev.icon_fallback')
  end

  def key
    from_address.status&.to_sym || :default
  end

  private

  attr_reader :from_address, :service_id, :messages

  def link
    govuk_link_to(
      messages[key][:link],
      Rails.application.routes.url_helpers.settings_from_address_index_path(service_id)
    )
  end
end
