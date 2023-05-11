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
  let(:default_json_endpoint) { 'https://www.api-endpoint.uk' }
  let(:default_json_key) { 'I-am-encoded-key' }

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

          it 'updates the service configuration endpoint url' do
            api_submission_settings_updater.create_or_update!
            service_configuration.reload
            expect(
              service_configuration.decrypt_value
            ).to eq(params[:service_output_json_endpoint])
          end
        end

        context 'when a user removes the value' do
          let(:params) { { service_output_json_endpoint: '' } }

          before do
            api_submission_settings_updater.create_or_update!
          end

          it 'delete the record' do
            assert_raises(ActiveRecord::RecordNotFound) do
              service_configuration.reload
            end
          end

          it 'shows the default json endpoint url' do
            expect(
              service_configuration.decrypt_value
            ).to eq(default_json_endpoint)
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

          it 'creates the service configuration for json endpoint' do
            expect(service_configuration).to be_persisted
            expect(
              service_configuration.decrypt_value
            ).to eq(params[:service_output_json_endpoint])
          end
        end
      end
    end

    context 'service_output_json_key' do
      context 'when service_output_json_key exists in the db' do
        let!(:service_configuration) do
          create(
            :service_configuration,
            :dev,
            :service_output_json_key,
            service_id: service.service_id
          )
        end

        context 'when a user updates the value' do
          let(:params) { { service_output_json_key: '98957af1a0424376' } }

          it 'updates the service configuration key' do
            api_submission_settings_updater.create_or_update!
            service_configuration.reload
            expect(
              service_configuration.decrypt_value
            ).to eq(params[:service_output_json_key])
          end
        end

        context 'when a user removes the value' do
          let(:params) { { service_output_json_key: '' } }

          before do
            api_submission_settings_updater.create_or_update!
          end

          it 'delete the record' do
            assert_raises(ActiveRecord::RecordNotFound) do
              service_configuration.reload
            end
          end

          it 'shows the default key' do
            expect(
              service_configuration.decrypt_value
            ).to eq(default_json_key)
          end
        end
      end

      context 'when service_output_json_key does not exist in db' do
        let(:service_configuration) do
          ServiceConfiguration.find_by(
            service_id: service.service_id,
            name: 'SERVICE_OUTPUT_JSON_KEY'
          )
        end

        context 'when an user adds a value' do
          let(:params) { { service_output_json_key: '98957af1a0424376' } }

          before do
            api_submission_settings_updater.create_or_update!
          end

          it 'creates the service configuration for json key' do
            expect(service_configuration).to be_persisted
            expect(
              service_configuration.decrypt_value
            ).to eq(params[:service_output_json_key])
          end
        end
      end
    end
  end
end
