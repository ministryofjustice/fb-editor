module ApplicationHelper
  include MetadataPresenter::ApplicationHelper

  def enabled_validations(component)
    EnabledValidationsPresenter.new(component).enabled_list
  end

  # Used on service flow page
  def flow_thumbnail_link(item)
    link_to edit_page_path(
      service.service_id, item[:uuid]
    ), class: "flow-thumbnail #{item[:thumbnail]} #{payment_link_enabled? ? 'payment-enabled' : ''}", 'aria-hidden': true, tabindex: -1 do
      concat image_pack_tag('thumbnails/thumbs_header.png', class: 'header', alt: '')
      concat tag.span("#{t('actions.edit')}: ", class: 'govuk-visually-hidden')
      concat tag.span(flow_item_title(item), class: 'text')
      concat image_pack_tag("thumbnails/thumbs_#{item[:thumbnail]}.jpg", class: 'body', alt: '')
    end
  end

  # # Used on service flow page
  # def flow_text_link(item)
  #   link_to (if item[:type] == 'flow.branch'
  #              edit_branch_path(service.service_id, item[:uuid])
  #            else
  #              edit_page_path(service.service_id, item[:uuid])
  #            end), class: 'govuk-link flow-item__title' do
  #     concat tag.span("#{t('actions.edit')}: ", class: 'govuk-visually-hidden')
  #     concat tag.span(flow_item_title(item), class: 'text')
  #   end
  # end
  #
  def flow_item_title(item)
    return item[:title] unless item[:type] == 'page.confirmation'
    return item[:title] unless payment_link_enabled?
    return item[:title] unless item[:title] == I18n.t('presenter.confirmation.application_complete')

    I18n.t('presenter.confirmation.payment_enabled')
  end

  # def flow_branch_link(item)
  #   link_to edit_branch_path(service.service_id, item[:uuid]), class: 'govuk-link flow-item__title' do
  #     concat(
  #       '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 125" tabindex="-1" focusable="false">
  #         <polygon fill="" points="1,62.5 100,1 199,62.5 100,124" stroke="" stroke-width="2"/>
  #         </svg>'.html_safe
  #     )
  #     concat tag.span("#{t('actions.edit')}: ", class: 'govuk-visually-hidden')
  #     concat tag.span(item[:title], class: 'text')
  #   end
  # end

  # rubocop:disable Rails/HelperInstanceVariable
  def pages_url
    case controller_name
    when 'pages'
      edit_service_path(service.service_id, anchor: @page&.uuid)
    when 'branches'
      edit_service_path(service.service_id, anchor: @branch&.branch_uuid)
    else
      edit_service_path(service.service_id)
    end
  end
  # rubocop:enable Rails/HelperInstanceVariable

  def strip_url(url)
    url.to_s.chomp('/').reverse.chomp('/').reverse.strip.downcase
  end

  def detached_edit_link(flow)
    if flow[:type] == 'flow.branch'
      edit_branch_path(service.service_id, flow[:uuid])
    else
      edit_page_path(service.service_id, flow[:uuid])
    end
  end

  def flow_thumbnail(page)
    type = if page.components.blank?
             page.type.gsub('page.', '')
           else
             page.components.first.type
           end
    flow_thumbnail_link(uuid: page.uuid, thumbnail: type, title: page.title)
  end

  def flow_title(flow_object)
    flow_object.title || service.find_page_by_uuid(flow_object.uuid).title
  end

  def editor_back_link(path)
    link_to path, class: 'fb-back-link' do
      concat tag.span '<svg width="7" height="12" viewBox="0 0 7 12" fill="none" role="image" aria-hidden="true">
        <path fill-rule="evenodd" clip-rule="evenodd" d="M5.75345 0L6.46045 0.706L1.41445 5.753L6.46045 10.799L5.75345 11.507L0.000449181 5.753L5.75345 0Z" fill="currentColor"/>
        </svg>'.html_safe
      concat tag.span 'Back'
    end
  end

  def moj_forms_admin?
    return if current_user.blank?

    Rails.application.config.moj_forms_admin.include?(current_user.email)
  end

  def moj_forms_dev?
    return if current_user.blank?

    Rails.application.config.moj_forms_devs.include?(current_user.email)
  end

  def items_present?(component_id)
    response = MetadataApiClient::Items.find(service_id: service.service_id, component_id:)

    return if response.errors?

    response.metadata['items'].present?
  end

  # Remove once hotjar testing is complete
  def live_platform?
    ENV['PLATFORM_ENV'] == 'live'
  end
  # Remove once hotjar testing is complete
end
