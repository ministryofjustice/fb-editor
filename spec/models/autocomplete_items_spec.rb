RSpec.describe AutocompleteItems do
  subject(:autocomplete_items) do
    described_class.new(
      service_id:,
      component_id:,
      file:
    )
  end
  let(:service_id) { SecureRandom.uuid }
  let(:component_id) { SecureRandom.uuid }
  let(:path_to_file) { Rails.root.join('spec', 'fixtures', 'autocomplete', 'valid.csv') }
  let(:file) { Rack::Test::UploadedFile.new path_to_file, 'text/csv' }
  before do
    allow(MalwareScanner).to receive(:call).and_return(false)
    subject.validate
  end

  context 'when validating a file' do
    context 'when a file is present' do
      it 'returns valid' do
        expect(subject).to be_valid
      end

      context 'when a file has a virus' do
        let(:expected_error) { [I18n.t('activemodel.errors.models.autocomplete_items.virus_found', attribute: file.original_filename)] }
        before do
          allow(MalwareScanner).to receive(:call).and_return(true)
        end

        it 'should be invalid' do
          expect(subject).to_not be_valid
        end

        it 'should not validate csv file' do
          expect_any_instance_of(CsvValidator).not_to receive(:validate)
        end

        it 'should have errors' do
          subject.valid?
          expect(subject.errors.full_messages).to eq(expected_error)
        end
      end

      context 'when a file is larger than 1MB' do
        let(:expected_error) { [I18n.t('activemodel.errors.models.autocomplete_items.too_big')] }

        before do
          allow(file).to receive(:size).and_return(2.megabytes)
        end

        it 'should be invalid' do
          expect(subject).to_not be_valid
        end

        it 'should not validate csv file' do
          expect_any_instance_of(CsvValidator).not_to receive(:validate)
        end

        it 'should have errors' do
          subject.valid?
          expect(subject.errors.full_messages).to eq(expected_error)
        end
      end
    end

    context 'when a file is not present' do
      let(:file) { nil }

      it 'returns invalid' do
        expect(subject).to_not be_valid
      end

      it 'does not validate the csv file' do
        expect_any_instance_of(CsvValidator).not_to receive(:validate)
        subject.valid?
      end
    end
  end

  describe '#file_headings' do
    context 'file has headings' do
      let(:expected_headings) { %w[Text Value] }

      it 'returns headings' do
        expect(subject.file_headings).to eq(expected_headings)
      end
    end
  end

  describe '#file_rows' do
    context 'has the correct file rows' do
      let(:expected_rows) { [%w[b 1], %w[c 2], %w[d 3]] }

      it 'returns the contents' do
        expect(subject.file_rows).to eq(expected_rows)
      end
    end
  end

  describe '#file_contents' do
    context 'file is malformed' do
      let(:path_to_file) { Rails.root.join('spec', 'fixtures', 'autocomplete', 'malformed.csv') }

      it 'is invalid' do
        expect(subject).to_not be_valid
      end

      it 'has the correct error message' do
        expect(subject.errors.full_messages).to eq([
          I18n.t('activemodel.errors.models.autocomplete_items.incorrect_format')
          ])
      end
    end

    context 'file has special characters' do
      let(:path_to_file) { Rails.root.join('spec', 'fixtures', 'autocomplete', 'special_characters.csv') }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end

    context 'has carriage return at the end of the file' do
      let(:path_to_file) { Rails.root.join('spec', 'fixtures', 'autocomplete', 'carriage_return.csv') }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end
  end
end
