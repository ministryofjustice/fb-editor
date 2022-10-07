module SettingsEmailHelper
  def email_settings_error_summary(object, deployment_environment)
    EmailSettingsErrorSummaryPresenter.new(object.errors.messages, deployment_environment)
  end

  def email_settings_field_id(builder, attribute_name, deployment_environment)
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
