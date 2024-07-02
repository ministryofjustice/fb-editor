RSpec.describe MsListSettingsUpdater do
  subject(:send_to_ms_list_settings_updater) do
    described_class.new(
      send_to_ms_list_settings:,
      service_id: service.service_id,
      service_name: service.service_name
    )
  end
  let(:send_to_ms_list_settings) do
    MsListSetting.new(
      params.merge(
        service_id: service.service_id
      )
    )
  end
  let(:params) { {} }

  describe '#create_or_update' do
    context 'when send to ms list settings exist in the db' do
      let(:params) { { send_to_ms_list: '1' } }

      before do
        create(
          :submission_setting,
          :send_to_graph_api,
          service_id: service.service_id,
          deployment_environment: 'dev'
        )

        send_to_ms_list_settings_updater.create_or_update!
      end
    end
  end
end
