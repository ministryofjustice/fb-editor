class EmailSettingsErrorSummaryPresenter
  def initialize(error_messages, environment)
    @error_messages = error_messages
    @environment = environment
  end

  def formatted_error_messages
    @error_messages.map { |attribute, messages| ["#{attribute}_#{@environment}", messages.first] }
  end
end
