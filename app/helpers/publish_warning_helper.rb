module PublishWarningHelper
  def submitting_pages_not_present
    if !checkanswers_present? && !confirmation_present?
      I18n.t('publish.warning.both_pages')
    end
  end

  def cya_page_not_present
    if !checkanswers_present? && confirmation_present?
      I18n.t('publish.warning.cya')
    end
  end

  def confirmation_page_not_present
    if checkanswers_present? && !confirmation_present?
      I18n.t('publish.warning.confirmation')
    end
  end

  def checkanswers_present?
    grid.page_uuids.include?(find_page_uuid('page.checkanswers'))
  end

  def confirmation_present?
    grid.page_uuids.include?(find_page_uuid('page.confirmation'))
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
