class Settings::SubmissionController < FormController
  def index
    @settings = Settings.new(service_name: service.service_name)
  end

  def page_title
    "#{I18n.t('settings.submission.heading')} - Settings - MoJ Forms"
  end
  helper_method :page_title
end
