RSpec.describe SaveAndReturnSettings do
  subject(:save_and_return_settings) do
    described_class.new(
      params.merge(service_id: service.service_id)
    )
  end
  let(:params) { {} }

  describe '#save_and_return_checked?' do
    context 'when save and return is ticked' do
      let(:params) { { save_and_return: '1' } }

      it 'returns true' do
        expect(save_and_return_settings.save_and_return_checked?).to be_truthy
      end

      it 'does not retrieve the record in the database' do
        expect(ServiceConfiguration).to_not receive(:exists?)
      end
    end

    context 'when save and return is not ticked' do
      let(:params) { { save_and_return: '0' } }

      it 'returns false' do
        expect(save_and_return_settings.save_and_return_checked?).to be_falsey
      end

      it 'does not retrieve the record in the database' do
        expect(ServiceConfiguration).to_not receive(:exists?)
      end
    end

    context 'save and return is nil' do
      context 'when there is a DB record' do
        before do
          create(
            :service_configuration,
            :save_and_return,
            service_id: service.service_id,
            deployment_environment: 'dev'
          )
          create(
            :service_configuration,
            :save_and_return,
            service_id: service.service_id,
            deployment_environment: 'production'
          )
        end

        it 'returns true' do
          expect(save_and_return_settings.save_and_return_checked?).to be_truthy
        end
      end
      context 'when there is no DB record' do
        it 'returns false' do
          expect(save_and_return_settings.save_and_return_checked?).to be_falsey
        end
      end
    end
  end
end
