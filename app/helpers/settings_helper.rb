module SettingsHelper
  def editor_settings_screen(back_link)
    content_tag :div, class: 'fb-settings-screen' do
      content_tag :div, class: 'govuk-grid-row' do
        content_tag :div, class: 'govuk-grid-column-two-thirds' do
          concat editor_back_link(back_link) if back_link
          yield
        end
      end
    end
  end
end
