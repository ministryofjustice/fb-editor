RSpec.describe Api::ApiController do
  describe '#items_present?' do
    before do
      allow(controller).to receive(:params).and_return(params)
    end

    context 'when items are present' do
      let(:params) { { items_present: 'true' } }

      it 'returns true' do
        expect(controller.items_present?).to be_truthy
      end
    end

    context 'when items are not present' do
      let(:params) { { items_present: 'false' } }

      it 'returns false' do
        expect(controller.items_present?).to be_falsey
      end
    end

    context 'when items_present is not present' do
      let(:params) { {} }

      it 'returns true' do
        expect(controller.items_present?).to be_falsey
      end
    end
  end
end
