class MsListSetting
  include ActiveModel::Model
  include ContentSubstitutorHelper

  attr_accessor :ms_site_id,
                :send_to_ms_list,
                :deployment_environment,
                :service

  validates :ms_list_id, :ms_site_id, presence: true

  def send_to_ms_list_checked?
    send_to_ms_list? || SubmissionSetting.find_by(
      service_id: service.service_id,
      deployment_environment:
    ).try(:send_to_graph_api?)
  end

  def value_for_list_id
    service_config = ServiceConfiguration.find_by(
      service_id: service.service_id,
      deployment_environment:,
      name: 'MS_LIST_ID'
    )
    service_config.present? ? service_config.decrypt_value : ''
  end

  def value_for_site_id
    service_config = ServiceConfiguration.find_by(
      service_id: service.service_id,
      deployment_environment:,
      name: 'MS_SITE_ID'
    )
    service_config.present? ? service_config.decrypt_value : ''
  end

  def value_for_drive_id
    service_config = ServiceConfiguration.find_by(
      service_id: service.service_id,
      deployment_environment:,
      name: 'MS_DRIVE_ID'
    )
    service_config.present? ? service_config.decrypt_value : ''
  end

  def send_to_ms_list?
    send_to_ms_list == '1'
  end
end
