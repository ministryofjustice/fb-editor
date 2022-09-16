module SettingsHelper
  def fb_settings_screen(back_link)
    content_tag :div, class: 'fb-settings-screen' do
      content_tag :div, class: 'govuk-grid-row' do
        content_tag :div, class: 'govuk-grid-column-two-thirds' do
          concat fb_back_link(back_link) if back_link
          yield
        end
      end
    end
  end
end
