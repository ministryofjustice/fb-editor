class PublishWarningPresenter
  attr_reader :service, :action

  MESSAGE = {
    publish: {
      both_pages: I18n.t('publish.warning.both_pages'),
      cya_page: I18n.t('publish.warning.cya'),
      confirmation_page: I18n.t('publish.warning.confirmation')
    },
    delete: {
      both_pages: I18n.t('pages.flow.delete_warning_both_pages'),
      cya_page: I18n.t('pages.flow.delete_warning_cya_page'),
      confirmation_page: I18n.t('pages.flow.delete_warning_confirmation_page')
    }
  }.freeze

  def initialize(service, action)
    @service = service
    @action = action
  end

  def message
    @message ||= submitting_pages_not_present_message ||
      confirmation_page_not_present_message ||
      cya_page_not_present_message
  end

  private

  def submitting_pages_not_present_message
    if !checkanswers_in_main_flow? && !confirmation_in_main_flow?
      MESSAGE[action][:both_pages]
    end
  end

  def cya_page_not_present_message
    if !checkanswers_in_main_flow? && confirmation_in_main_flow?
      MESSAGE[action][:cya_page]
    end
  end

  def confirmation_page_not_present_message
    if checkanswers_in_main_flow? && !confirmation_in_main_flow?
      MESSAGE[action][:confirmation_page]
    end
  end

  def checkanswers_in_main_flow?
    grid.page_uuids.include?(service.checkanswers_page&.uuid)
  end

  def confirmation_in_main_flow?
    grid.page_uuids.include?(service.confirmation_page&.uuid)
  end

  def grid
    @grid ||= MetadataPresenter::Grid.new(service)
  end
end
