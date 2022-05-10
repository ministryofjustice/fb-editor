RSpec.shared_examples 'a string length validation' do
  describe '#component_partial' do
    it 'returns the correct shared string length partial' do
      expect(subject.component_partial).to eq('string_length_validation')
    end
  end

  describe '#preselect_characters?' do
    context 'when no string validation has been configured previously configured' do
      it 'returns true (default selected radio)' do
        expect(subject.preselect_characters?).to be_truthy
      end
    end

    context 'when a word validation has been configured' do
      let(:latest_metadata) do
        meta = metadata_fixture(:version)
        meta['pages'][9]['components'][0]['validation'] = { 'max_word' => '1000' }
        meta
      end

      it 'returns false' do
        expect(subject.preselect_characters?).to be_falsey
      end
    end

    context 'when a character validation has been previously configured' do
      let(:page_uuid) { '9e1ba77f-f1e5-42f4-b090-437aa9af7f73' } # name
      let(:component_uuid) { '27d377a2-6828-44ca-87d1-b83ddac98284' }

      it 'returns true' do
        expect(subject.preselect_characters?).to be_truthy
      end
    end
  end

  describe '#previously_enabled?' do
    context 'when string_length property does not exists in component validation' do
      it 'returns falsey' do
        expect(subject.previously_enabled?).to be_falsey
      end
    end

    context 'when string_length property exists in component validation' do
      let(:page_uuid) { '9e1ba77f-f1e5-42f4-b090-437aa9af7f73' } # name
      let(:component_uuid) { '27d377a2-6828-44ca-87d1-b83ddac98284' }

      it 'returns truthy' do
        expect(subject.previously_enabled?).to be_truthy
      end
    end
  end
end
