class MsListSetting
  include ActiveModel::Model
  include ContentSubstitutorHelper

  attr_accessor :ms_list_id,
                :send_to_ms_list,
                :deployment_environment,
                :service

  attr_reader :send_to_ms_list_dev, :send_to_ms_list_production

  validates :ms_list_id, presence: true

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

  def send_to_ms_list?
    send_to_ms_list == '1'
  end
end
