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
  let(:an_existing_user) { 'legolas@middle-earth.co.uk' }
  let(:user) { create :user }

  describe '#update' do
    context 'when valid' do
      let(:params) { { form_owner: an_existing_user } }
      let(:service) { double(id: service_id, errors?: false) }
      let(:all_users) { Array(user) }
      let(:legolas_uuid) { User.first.id }

      before do
        allow(User).to receive(:all).and_return(all_users)
        expect(MetadataApiClient::Version).to receive(:create).with(
          service_id:,
          payload: { created_by: legolas_uuid }
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
