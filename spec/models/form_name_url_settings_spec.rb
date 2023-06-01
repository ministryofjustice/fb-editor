RSpec.describe FormNameUrlSettings do
  subject(:form_name_url_settings) do
    described_class.new(
      params.merge(
        service_id: '24601',
        latest_metadata:
      )
    )
  end
  let(:latest_metadata) do
    { service_name: 'a service name' }
  end

  describe '#create' do
    context 'when valid' do
      let(:params) do
        { service_name: 'another service name', service_slug: 'a-valid-slug' }
      end
      let(:service) do
        double(id: '05e12a93-3978-4624-a875-e59893f2c262', errors?: false)
      end

      before do
        expect(MetadataApiClient::Version).to receive(:create).with(
          service_id: '24601',
          payload: { service_name: 'another service name' }
        ).and_return(service)
      end

      it 'returns true' do
        expect(form_name_url_settings.create).to be_truthy
      end
    end

    context 'when invalid' do
      context 'service_name' do
        context 'when blank' do
          let(:params) { { service_name: '' } }

          it 'returns false' do
            expect(form_name_url_settings.create).to be_falsey
          end
        end

        context 'when too long' do
          let(:params) { { service_name: 'hi' * 160 } }

          it 'returns false' do
            expect(form_name_url_settings.create).to be_falsey
          end
        end

        context 'when too short' do
          let(:params) { { service_name: 'HI' } }

          it 'returns false' do
            expect(form_name_url_settings.create).to be_falsey
          end
        end
      end

      context 'service_slug' do
        context 'when blank' do
          let(:params) { { service_slug: '' } }

          it 'returns false' do
            expect(form_name_url_settings.create).to be_falsey
          end
        end

        context 'when too long' do
          let(:params) { { service_slug: 'hi' * 58 } }

          it 'returns false' do
            expect(form_name_url_settings.create).to be_falsey
          end
        end

        context 'when too short' do
          let(:params) { { service_slug: 'ss' } }

          it 'returns false' do
            expect(form_name_url_settings.create).to be_falsey
          end
        end

        context 'when begins with a number' do
          let(:params) { { service_slug: '001ss' } }

          it 'returns false' do
            expect(form_name_url_settings.create).to be_falsey
          end
        end

        context 'when spaces' do
          let(:params) { { service_slug: 'an invalid service slug' } }

          it 'returns false' do
            expect(form_name_url_settings.create).to be_falsey
          end
        end
      end
    end
  end
end
