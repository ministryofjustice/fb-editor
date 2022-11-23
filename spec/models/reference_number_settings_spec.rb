RSpec.describe ReferenceNumberSettings do
  subject(:reference_number_settings) do
    described_class.new(
      params.merge(service_id: service.service_id)
    )
  end
  let(:params) { {} }

  describe '#reference_number_enabled?' do
    context 'when reference number is ticked' do
      let(:params) { { reference_number: '1' } }

      it 'returns true' do
        expect(reference_number_settings.reference_number_checked?).to be_truthy
      end

      context 'when reference number is not ticked' do
        let(:params) { { reference_number: '0' } }

        it 'returns false' do
          expect(reference_number_settings.reference_number_checked?).to be_falsey
        end
      end
    end
  end
end
