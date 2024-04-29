RSpec.describe MsListSetting do
  subject(:ms_list_settings) do
    described_class.new(
      params.merge(service:)
    )
  end
  let(:params) { {} }

  describe '#send_to_ms_list_checked?' do
    context 'when send to ms list is ticked' do
      let(:params) { { send_to_ms_list: '1' } }

      it 'returns true' do
        expect(ms_list_settings.send_to_ms_list_checked?).to be_truthy
      end

      it 'does not retrieve the record in the database' do
        expect(ServiceConfiguration).to_not receive(:exists?)
      end
    end

    context 'when send to ms list is not ticked' do
      let(:params) { { send_to_ms_list: '0' } }

      it 'returns false' do
        expect(ms_list_settings.send_to_ms_list_checked?).to be_falsey
      end

      it 'does not retrieve the record in the database' do
        expect(ServiceConfiguration).to_not receive(:exists?)
      end
    end

    context 'send to ms list is nil' do
      context 'when there is a DB record' do
        before do
          create(
            :submission_setting,
            :send_to_graph_api,
            service_id: service.service_id,
            deployment_environment: 'dev'
          )
          ms_list_settings.deployment_environment = 'dev'
        end

        it 'returns true' do
          expect(ms_list_settings.send_to_ms_list_checked?).to be_truthy
        end
      end
      context 'when there is no DB record' do
        before do
          ms_list_settings.deployment_environment = 'production'
        end

        it 'returns false' do
          expect(ms_list_settings.send_to_ms_list_checked?).to be_falsey
        end
      end
    end

    context 'value for field' do
      context 'configuration driven check' do
        %w[
          MS_LIST_ID
          MS_SITE_ID
          MS_DRIVE_ID
        ].each do |field|
          context "field: #{field}" do
            it 'uses the value of the object when present, or defaults to empty string, or the configuration if found' do
              ms_list_settings.deployment_environment = 'dev'

              expect(ms_list_settings.send("value_for#{field.downcase.slice(2, field.length)}")).to eq('')

              create(
                :service_configuration,
                service_id: service.service_id,
                deployment_environment: 'dev',
                name: field,
                value: "#{field.downcase}-value"
              )

              expect(ms_list_settings.send("value_for#{field.downcase.slice(2, field.length)}")).to eq("#{field.downcase}-value")
            end
          end
        end
      end
    end
  end
end
