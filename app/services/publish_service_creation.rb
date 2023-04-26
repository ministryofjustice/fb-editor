class PublishServiceCreation
  include ActiveModel::Model
  REQUIRE_AUTHENTICATION = '1'.freeze

  attr_accessor :service_id,
                :service_name,
                :version_id,
                :user_id,
                :deployment_environment,
                :require_authentication,
                :username,
                :password,
                :publish_service_id

  validates :service_id, :service_name, :version_id, :user_id, presence: true
  with_options if: :require_authentication? do |record|
    record.validates :username, presence: { message: I18n.t(
      'activemodel.errors.models.publish_service_creation.blank_username'
    ) }
    record.validates :username, allow_blank: true, length: {
      minimum: 6,
      maximum: 50,
      message: I18n.t(
        'activemodel.errors.models.publish_service_creation.username_too_short'
      )
    }
    record.validates :password, presence: { message: I18n.t(
      'activemodel.errors.models.publish_service_creation.blank_password'
    ) }
    record.validates :password, allow_blank: true, length: {
      minimum: 6,
      maximum: 50,
      message: I18n.t(
        'activemodel.errors.models.publish_service_creation.password_too_short'
      )
    }
  end

  def save
    return false if invalid?

    ActiveRecord::Base.transaction do
      create_publish_service

      if require_authentication?
        create_service_configurations
      else
        delete_service_configurations
      end
    end

    true
  end

  def service_configuration(name:, deployment_environment:)
    configuration = ServiceConfiguration.find_by(
      service_id:,
      deployment_environment:,
      name: name.to_s.upcase
    )

    configuration.decrypt_value if configuration.present?
  end

  def existing_authentication?(deployment_environment:)
    PublishService.completed.where(
      service_id:,
      deployment_environment:
    ).count.zero? || service_configuration(
      name: ServiceConfiguration::BASIC_AUTH_USER,
      deployment_environment:
    ).present?
  end

  def no_service_output?
    send_by_email.blank? || (send_by_email.present? && service_email_output.blank?)
  end

  private

  def create_publish_service
    publish_service.save!
    @publish_service_id = publish_service.id
  end

  def create_service_configurations
    create_or_update_configuration(
      name: ServiceConfiguration::BASIC_AUTH_USER, value: username
    )
    create_or_update_configuration(
      name: ServiceConfiguration::BASIC_AUTH_PASS, value: password
    )
    create_or_update_configuration(
      name: 'SAVE_AND_RETURN', value: 'enabled'
    )
    create_or_update_configuration(
      name: 'SAVE_AND_RETURN_EMAIL',
      value: I18n.t('default_values.save_and_return_email', service_name:)
    )
  end

  def delete_service_configurations
    delete_service_configuration(name: ServiceConfiguration::BASIC_AUTH_USER)
    delete_service_configuration(name: ServiceConfiguration::BASIC_AUTH_PASS)
  end

  def publish_service
    @publish_service ||= PublishService.new(
      service_id:,
      user_id:,
      version_id:,
      deployment_environment:,
      status: :queued
    )
  end

  def create_or_update_configuration(name:, value:)
    service_configuration = ServiceConfiguration.find_or_initialize_by(
      service_id:,
      deployment_environment:,
      name:
    )
    service_configuration.value = value
    service_configuration.save!
  end

  def delete_service_configuration(name:)
    ServiceConfiguration.destroy_by(
      service_id:,
      deployment_environment:,
      name:
    )
  end

  def create_or_update_configuration(name:, value:)
    service_configuration = ServiceConfiguration.find_or_initialize_by(
      service_id:,
      deployment_environment:,
      name:
    )
    service_configuration.value = value
    service_configuration.save!
  end

  def require_authentication?
    require_authentication == if deployment_environment == 'dev'
                                '1'
                              else
                                REQUIRE_AUTHENTICATION
                              end
  end

  def send_by_email
    @send_by_email ||= SubmissionSetting.find_by(
      service_id:,
      deployment_environment:
    ).try(:send_email?)
  end

  def service_email_output
    ServiceConfiguration.find_by(
      service_id:,
      deployment_environment:,
      name: 'SERVICE_EMAIL_OUTPUT'
    )
  end

  def service_csv_output
    SubmissionSetting.find_by(
      service_id:,
      deployment_environment:
    ).try(:service_csv_output?)
  end
end
