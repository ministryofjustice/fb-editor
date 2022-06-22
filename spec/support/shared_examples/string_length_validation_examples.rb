RSpec.shared_examples 'a string length validation' do
  describe '#component_partial' do
    it 'returns the correct shared string length partial' do
      expect(subject.component_partial).to eq('string_length_validation')
    end
  end

  describe '#select_characters?' do
    context 'when no string validation has been configured previously configured' do
      context 'when value is empty' do
        let(:value) { nil }

        context 'when string length is characters' do
          it 'returns true' do
            expect(subject.select_characters?).to be_truthy
          end
        end

        context 'when string length is words' do
          let(:string_length) { 'max_word' }

          it 'returns false' do
            expect(subject.select_characters?).to be_falsey
          end
        end
      end

      context 'when string length does not exist (GET request for modal)' do
        let(:string_length) { nil }
        let(:value) { nil }

        it 'returns true (default selected radio)' do
          expect(subject.select_characters?).to be_truthy
        end
      end
    end

    context 'when a word validation has been configured' do
      let(:latest_metadata) do
        meta = metadata_fixture(:version)
        meta['pages'][9]['components'][0]['validation'] = { 'max_word' => '1000' }
        meta
      end

      it 'returns false' do
        expect(subject.select_characters?).to be_falsey
      end
    end

    context 'when a character validation has been previously configured' do
      let(:page_uuid) { '9e1ba77f-f1e5-42f4-b090-437aa9af7f73' } # name
      let(:component_uuid) { '27d377a2-6828-44ca-87d1-b83ddac98284' }

      it 'returns true' do
        expect(subject.select_characters?).to be_truthy
      end
    end
  end

  describe '#select_words?' do
    context 'when no string validation has been configured previously configured' do
      context 'when value is empty' do
        let(:value) { nil }

        context 'when string length is characters' do
          it 'returns false' do
            expect(subject.select_words?).to be_falsey
          end
        end

        context 'when string length is words' do
          let(:string_length) { 'max_word' }

          it 'returns true' do
            expect(subject.select_words?).to be_truthy
          end
        end
      end

      context 'when string length does not exist (GET request for modal)' do
        let(:string_length) { nil }
        let(:value) { nil }

        it 'returns false' do
          expect(subject.select_words?).to be_falsey
        end
      end
    end

    context 'when a characters validation has been configured' do
      let(:latest_metadata) do
        meta = metadata_fixture(:version)
        meta['pages'][9]['components'][0]['validation'] = { 'min_length' => '5' }
        meta
      end

      it 'returns false' do
        expect(subject.select_words?).to be_falsey
      end
    end

    context 'when a word validation has been previously configured' do
      let(:latest_metadata) do
        meta = metadata_fixture(:version)
        meta['pages'][9]['components'][0]['validation'] = { 'min_word' => '500' }
        meta
      end
      let(:string_length) { 'min_word' }

      it 'returns true' do
        expect(subject.select_words?).to be_truthy
      end
    end
  end
end
