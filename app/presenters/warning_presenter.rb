class WarningPresenter
  attr_reader :service, :action

  def initialize(service = nil)
    @service = service
  end

  def message
    @message ||= submitting_pages_not_present_message ||
      confirmation_page_not_present_message ||
      cya_page_not_present_message
  end

  def cya_and_confirmation_missing?
    !checkanswers_in_main_flow &&
      !confirmation_in_main_flow
  end

  def confirmation_in_main_flow
    @confirmation_in_main_flow ||= grid.page_uuids.include?(service.confirmation_page&.uuid)
  end

  private

  def submitting_pages_not_present_message
    if cya_and_confirmation_missing?
      messages[:both_pages]
    end
  end

  def cya_page_not_present_message
    if !checkanswers_in_main_flow && confirmation_in_main_flow
      messages[:cya_page]
    end
  end

  def confirmation_page_not_present_message
    if checkanswers_in_main_flow && !confirmation_in_main_flow
      messages[:confirmation_page]
    end
  end

  def checkanswers_in_main_flow
    @checkanswers_in_main_flow ||= grid.page_uuids.include?(service.checkanswers_page&.uuid)
  end

  def grid
    @grid ||= MetadataPresenter::Grid.new(service)
  end
end
