class PublishWarningPresenter
  attr_reader :service

  def initialize(service)
    @service = service
  end

  def warning_message
    submitting_pages_not_present_message ||
      confirmation_page_not_present_message ||
      cya_page_not_present_message
  end

  def submitting_pages_not_present_message
    if !checkanswers_in_main_flow? && !confirmation_in_main_flow?
      I18n.t('publish.warning.both_pages')
    end
  end

  def cya_page_not_present_message
    if !checkanswers_in_main_flow? && confirmation_in_main_flow?
      I18n.t('publish.warning.cya')
    end
  end

  def confirmation_page_not_present_message
    if checkanswers_in_main_flow? && !confirmation_in_main_flow?
      I18n.t('publish.warning.confirmation')
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
