class SubmissionWarningsPresenter
  attr_reader :presenters, :deployment_environment

  def initialize(presenters, deployment_environment)
    @presenters = presenters
    @deployment_environment = deployment_environment
  end

  def heading
    I18n.t("warnings.publish.#{deployment_environment}.heading")
  end

  def icon_fallback
    I18n.t("warnings.publish.#{deployment_environment}.icon_fallback")
  end

  def messages
    presenters.map(&:message).compact.flatten
  end
end
