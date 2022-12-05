RSpec.describe ReferencePaymentSettings do
  subject(:reference_payment_settings) do
    described_class.new(
      params.merge(service_id: service.service_id)
    )
  end
  let(:params) { {} }

  describe '#reference_number_checked?' do
    context 'when reference number is ticked' do
      let(:params) { { reference_number: '1' } }

      it 'returns true' do
        expect(reference_payment_settings.reference_number_checked?).to be_truthy
      end

      context 'when reference number is not ticked' do
        let(:params) { { reference_number: '0' } }

        it 'returns false' do
          expect(reference_payment_settings.reference_number_checked?).to be_falsey
        end
      end
    end
  end

  describe '#payment_link_url_enabled?' do
    context 'when payment link url is present' do
      let(:params) { { payment_link_url: 'www.payment_link.gov' } }

      it 'returns true' do
        expect(reference_payment_settings.payment_link_url_enabled?).to be_truthy
      end
    end

    context 'when payment link url is not present' do
      let(:params) { { payment_link_url: '' } }

      it 'returns false' do
        expect(reference_payment_settings.payment_link_url_enabled?).to be_falsey
      end
    end
  end
end
