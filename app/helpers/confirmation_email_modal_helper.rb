module ConfirmationEmailModalHelper
  def confirmation_email_setting_checked?
    confirmation_email_checked_in_dev? || confirmation_email_checked_in_production?
  end

  def confirmation_email_component_ids
    if confirmation_email_checked_in_both?
      [confirmation_email_component_id_dev.decrypt_value].push(
        confirmation_email_component_id_production.decrypt_value
      )
    elsif confirmation_email_checked_in_dev?
      [confirmation_email_component_id_dev.decrypt_value]
    else
      [confirmation_email_component_id_production.decrypt_value]
    end
  end

  def confirmation_email_checked_in_both?
    confirmation_email_checked_in_dev? && confirmation_email_checked_in_production?
  end

  def confirmation_email_component_id_dev
    @confirmation_email_component_id_dev ||= ServiceConfiguration.find_by(
      service_id: service.service_id,
      deployment_environment: 'dev',
      name: 'CONFIRMATION_EMAIL_COMPONENT_ID'
    )
  end

  def confirmation_email_component_id_production
    @confirmation_email_component_id_production ||= ServiceConfiguration.find_by(
      service_id: service.service_id,
      deployment_environment: 'production',
      name: 'CONFIRMATION_EMAIL_COMPONENT_ID'
    )
  end

  def confirmation_email_checked_in_dev?
    @confirmation_email_checked_in_dev ||=
      SubmissionSetting.where(
        service_id: service.service_id,
        deployment_environment: 'dev'
      ).pick(:send_confirmation_email)
  end

  def confirmation_email_checked_in_production?
    @confirmation_email_checked_in_production ||=
      SubmissionSetting.where(
        service_id: service.service_id,
        deployment_environment: 'production'
      ).pick(:send_confirmation_email)
  end
end
