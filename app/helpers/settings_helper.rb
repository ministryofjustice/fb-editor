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

  def settings_error_summary(object, deployment_environment)
    EmailSettingsErrorSummaryPresenter.new(object.errors.messages, deployment_environment)
  end

  def settings_field_id(builder, attribute_name, deployment_environment)
    id_type = builder.object.errors.messages[attribute_name].present? ? 'field-error' : 'field'
    [
      builder.object.class.name.underscore,
      attribute_name,
      deployment_environment,
      id_type
    ]
    .compact
    .join('-')
    .gsub('_', '-')
  end
end
