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
    if ENV['FROM_ADDRESS'] == 'enabled'
      presenters.map(&:message).compact
    else
      presenters.reject { |p| p.is_a?(FromAddressPresenter) }
                .map(&:message).compact
    end
  end
end
