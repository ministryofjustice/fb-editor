RSpec.describe AutocompleteItems do
  subject(:autocomplete_items) do
    described_class.new(
      service_id: service_id,
      component_id: component_id,
      file: file
    )
  end
  let(:service_id) { SecureRandom.uuid }
  let(:component_id) { SecureRandom.uuid }
  let(:path_to_file) { Rails.root.join('spec', 'fixtures', 'valid.csv') }
  let(:file) { Rack::Test::UploadedFile.new path_to_file, 'text/csv' }
  before do
    subject.validate
  end

  context 'when validating a file' do
    context 'when a file is present' do
      it 'returns valid' do
        expect(subject).to be_valid
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
      let(:expected_headings) { %w[text value] }

      it 'returns headings' do
        expect(subject.file_headings).to eq(expected_headings)
      end
    end
  end

  describe '#file_values' do
    context 'has the correct file values' do
      let(:expected_values) { [%w[b 1], %w[c 2], %w[d 3]] }

      it 'returns the contents' do
        expect(subject.file_values).to eq(expected_values)
      end
    end
  end

  describe '#file_contents' do
    context 'file is malformed' do
      let(:path_to_file) { Rails.root.join('spec', 'fixtures', 'malformed.csv') }

      it 'is invalid' do
        expect(subject).to_not be_valid
      end

      it 'has the correct error message' do
        expect(subject.errors.full_messages).to eq([
          I18n.t(
            'activemodel.errors.models.autocomplete_items.incorrect_format'
          )
        ])
      end
    end

    context 'file has special characters' do
      let(:path_to_file) { Rails.root.join('spec', 'fixtures', 'special_characters.csv') }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end
  end
end
