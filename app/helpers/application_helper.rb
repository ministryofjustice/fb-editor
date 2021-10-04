module ApplicationHelper
  include MetadataPresenter::ApplicationHelper

  # Used on service flow page
  def flow_thumbnail_link(args)
    link_to edit_page_path(
      service.service_id, args[:uuid]
    ), class: "flow-thumbnail #{args[:thumbnail]}", 'aria-hidden': true do
      concat image_pack_tag('thumbnails/thumbs_header.png', class: 'header', alt: '')
      concat tag.span("#{t('actions.edit')}: ", class: 'govuk-visually-hidden')
      concat tag.span(args[:title], class: 'text')
      concat image_pack_tag("thumbnails/thumbs_#{args[:thumbnail]}.jpg", class: 'body', alt: '')
    end
  end

  # Used on service flow page
  def flow_text_link(item)
    link_to (if item[:type] == 'flow.branch'
               edit_branch_path(service.service_id, item[:uuid])
             else
               edit_page_path(service.service_id, item[:uuid])
             end), class: 'govuk-link' do
      concat tag.span("#{t('actions.edit')}: ", class: 'govuk-visually-hidden')
      concat tag.span(item[:title], class: 'text')
    end
  end

  def strip_url(url)
    url.to_s.chomp('/').reverse.chomp('/').reverse.strip.downcase
  end

  # START: Remove once new service flow page is finished
  def flow_thumbnail(page)
    type = if page.components.blank?
             page.type.gsub('page.', '')
           else
             page.components.first.type
           end
    flow_thumbnail_link(uuid: page.uuid, thumbnail: type, title: page.title)
  end
  # END: Remove once new service flow page is finished

  def flow_title(flow_object)
    flow_object.title || service.find_page_by_uuid(flow_object.uuid).title
  end

  def moj_forms_dev?
    Rails.application.config.moj_forms_devs.include?(current_user.email)
  end

  # Remove once hotjar testing is complete
  def live_platform?
    ENV['PLATFORM_ENV'] == 'live'
  end
  # Remove once hotjar testing is complete
end
