class SettingsController < FormController
  def page_title
    if @page
      if @page.heading
        "Form Settings - #{service.service_name} - MoJ Forms Editor"
      end
    else
      super
    end
  end
  helper_method :page_title
end
