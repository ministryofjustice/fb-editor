RSpec.describe FormAnalyticsUpdater do
  subject(:form_analytics_updater) do
    described_class.new(settings: settings, service_id: service.service_id)
  end
  let(:settings) do
    FormAnalyticsSettings.new(base_params.merge(params))
  end
  let(:base_params) do
    {
      service_id: service.service_id,
      deployment_environment: deployment_environment,
      enabled: enabled
    }
  end
  let(:params) { {} }
  let(:deployment_environment) { 'dev' }
  let(:enabled) { '1' }

  describe '#create_or_update!' do
    context 'when enabled' do
      context 'when config param is present' do
        context 'when config already exists in db' do
          let!(:service_configuration) do
            create(:service_configuration, :dev, :ua, service_id: service.service_id)
          end
          let(:params) { { ua: 'UA-98765' } }

          it 'updates the value' do
            subject.create_or_update!
            service_configuration.reload
            expect(service_configuration.decrypt_value).to eq(params[:ua])
          end
        end

        context 'when config does not exist in the db' do
          let(:service_configuration) do
            ServiceConfiguration.find_by(
              service_id: service.service_id,
              deployment_environment: 'dev',
              name: 'GTM'
            )
          end
          let(:params) { { gtm: 'GTM-98765' } }

          before do
            subject.create_or_update!
          end

          it 'saves the value to the db' do
            expect(service_configuration).to be_persisted
            expect(service_configuration.decrypt_value).to eq(params[:gtm])
          end
        end
      end

      context 'when config param is not present' do
        context 'when config param exists in the db' do
          let!(:service_configuration) do
            create(:service_configuration, :dev, :ga4, service_id: service.service_id)
          end
          let(:params) { { ga4: '' } }

          it 'removes the config from the db' do
            subject.create_or_update!

            expect { service_configuration.reload }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end

    context 'when not enabled' do
      let(:enabled) { nil }

      context 'when configs exist in the db' do
        let!(:ua_config) do
          create(:service_configuration, :dev, :ua, service_id: service.service_id)
        end
        let!(:gtm_config) do
          create(:service_configuration, :dev, :gtm, service_id: service.service_id)
        end
        let!(:ga4_config) do
          create(:service_configuration, :dev, :ga4, service_id: service.service_id)
        end

        it 'removes all the configs from the db' do
          subject.create_or_update!

          expect { ua_config.reload }.to raise_error(ActiveRecord::RecordNotFound)
          expect { gtm_config.reload }.to raise_error(ActiveRecord::RecordNotFound)
          expect { ga4_config.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
