RSpec.describe FormOwnerSettings do
  subject(:form_owner_settings) do
    described_class.new(
      params.merge(
        service_id:,
        metadata:
      )
    )
  end
  let(:service_id) { SecureRandom.uuid }
  let(:metadata) { { created_by: 'original author' } }
  let(:an_existing_user) { 'fb-acceptance-tests@digital.justice.gov.uk' }

  describe '#update' do
    context 'when valid' do
      let(:params) { { form_owner: an_existing_user } }
      let(:service) { double(id: service_id, errors?: false) }

      before do
        expect(MetadataApiClient::Version).to receive(:create).with(
          service_id:,
          payload: { created_by: 'a reviewer' }
        ).and_return(service)
      end

      it 'returns true' do
        expect(form_owner_settings.update).to be_truthy
      end
    end

    context 'when invalid' do
      context 'created_by' do
        context 'when blank' do
          let(:params) { { form_owner: '' } }

          it 'returns false' do
            expect(form_owner_settings.update).to be_falsey
          end
        end
        context 'when address is invalid' do
          let(:params) { { form_owner: 'a reviewer' } }

          it 'returns false' do
            expect(form_owner_settings.update).to be_falsey
          end
        end
        context 'when address is valid but unknown' do
          let(:params) { { form_owner: 'em@il' } }

          it 'returns false' do
            expect(form_owner_settings.update).to be_falsey
          end
        end
      end
    end
  end
end
