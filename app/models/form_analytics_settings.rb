class FormAnalyticsSettings
  include ActiveModel::Model
  attr_accessor :deployment_environment,
                :service,
                :enabled,
                :gtm,
                :ga

  def enabled?
    enabled == '1'
  end
end
