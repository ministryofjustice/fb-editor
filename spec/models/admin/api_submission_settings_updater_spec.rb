RSpec.describe Admin::ApiSubmissionSettingsUpdater do
  subject(:api_submission_settings_updater) do
    described_class.new(
      api_submission_settings: Admin::ApiSubmissionSettings.new(
        params.merge(
          service:,
          deployment_environment: 'dev'
        )
      ),
      service:
    )
  end
  let(:params) { {} }
  let(:default_json_endpoint) do
    api_submission_settings_updater.api_submission_settings.default_value('service_output_json_endpoint')
  end
  let(:default_json_key) do
    api_submission_settings_updater.api_submission_settings.default_value('service_output_json_key')
  end

  describe '#create_or_update' do
    context 'service_output_json_endpoint' do
      context 'when service_output_json_endpoint exists in the db' do
        let!(:service_configuration) do
          create(
            :service_configuration,
            :dev,
            :service_output_json_endpoint,
            service_id: service.service_id
          )
        end

        context 'when a user updates the value' do
          let(:params) { { service_output_json_endpoint: 'http://endpoint.url' } }

          it 'updates the service configuration subject' do
            api_submission_settings_updater.create_or_update!
            service_configuration.reload
            expect(
              service_configuration.decrypt_value
            ).to eq(params[:service_output_json_endpoint])
          end
        end
      end

      context 'when service_output_json_endpoint does not exist in db' do
        let(:service_configuration) do
          ServiceConfiguration.find_by(
            service_id: service.service_id,
            name: 'SERVICE_OUTPUT_JSON_ENDPOINT'
          )
        end

        context 'when an user adds a value' do
          let(:params) { { service_output_json_endpoint: 'http://endpoint.url' } }

          before do
            api_submission_settings_updater.create_or_update!
          end

          it 'creates the service configuration json endpoint' do
            expect(service_configuration).to be_persisted
            expect(
              service_configuration.decrypt_value
            ).to eq(params[:service_output_json_endpoint])
          end
        end
      end
    end
  end
end
