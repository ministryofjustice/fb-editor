class SubmissionPresenter
  attr_reader :presenters

  def initialize(presenters)
    @presenters = presenters
  end

  def heading
    'Your form has issue(s) preventing submissions from being sent'
  end
end
