class PublishPresenter < WarningPresenter
  attr_reader :messages

  def initialize(service, messages)
    @messages = messages
    super(service)
  end
end
