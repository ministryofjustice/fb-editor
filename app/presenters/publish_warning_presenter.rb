class PublishWarningPresenter
  attr_reader :service

  def initialize(service)
    @service = service
  end

  def warning_message(warning_both_pages, warning_cya_page, warning_confirmation_page)
    submitting_pages_not_present_message(warning_both_pages) ||
      confirmation_page_not_present_message(warning_confirmation_page) ||
      cya_page_not_present_message(warning_cya_page)
  end

  def publish_warning_message
    warning_both_pages = 'publish.warning.both_pages'
    warning_cya_page = 'publish.warning.cya'
    warning_confirmation_page = 'publish.warning.confirmation'

    warning_message(warning_both_pages, warning_cya_page, warning_confirmation_page)
  end

  def delete_warning_message
    warning_both_pages = 'pages.flow.delete_warning_both_pages'
    warning_cya_page = 'pages.flow.delete_warning_cya_page'
    warning_confirmation_page = 'pages.flow.delete_warning_confirmation_page'

    warning_message(warning_both_pages, warning_cya_page, warning_confirmation_page)
  end

  def submitting_pages_not_present_message(message)
    if !checkanswers_in_main_flow? && !confirmation_in_main_flow?
      I18n.t(message)
    end
  end

  def cya_page_not_present_message(message)
    if !checkanswers_in_main_flow? && confirmation_in_main_flow?
      I18n.t(message)
    end
  end

  def confirmation_page_not_present_message(message)
    if checkanswers_in_main_flow? && !confirmation_in_main_flow?
      I18n.t(message)
    end
  end

  def checkanswers_in_main_flow?
    grid.page_uuids.include?(find_page_uuid('page.checkanswers'))
  end

  def confirmation_in_main_flow?
    grid.page_uuids.include?(find_page_uuid('page.confirmation'))
  end

  def checkanswers_in_service?
    service_includes_page?('page.checkanswers')
  end

  def confirmation_in_service?
    service_includes_page?('page.confirmation')
  end

  def find_page_uuid(page_type)
    if service_includes_page?(page_type)
      matched_page =
        service.pages.find do |page|
          page.type == page_type
        end
      matched_page.uuid
    end
  end

  def service_includes_page?(page)
    service.pages
      .map(&:type)
      .include?(page)
  end

  def grid
    @grid ||= MetadataPresenter::Grid.new(service)
  end
end
