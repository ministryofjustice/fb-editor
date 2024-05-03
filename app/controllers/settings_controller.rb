class SettingsController < FormController
  def page_title
    "Form Settings - #{service.service_name} - MoJ Forms Editor"
  end
  helper_method :page_title
end
