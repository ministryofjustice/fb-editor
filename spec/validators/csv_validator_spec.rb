RSpec.describe CsvValidator do
  let(:subject) { AutocompleteItems.new(params) }
  let(:params) do
    {
      service_id: service_id,
      component_id: component_id,
      file: file
    }
  end
  let(:service_id) { SecureRandom.uuid }
  let(:component_id) { SecureRandom.uuid }
  let(:path_to_file) { Rails.root.join('spec', 'fixtures', 'valid.csv') }
  let(:file) { Rack::Test::UploadedFile.new(path_to_file, 'text/csv') }

  describe '#validate' do
    before { subject.validate }

    context 'when not a csv file' do
      let(:path_to_file) { Rails.root.join('spec', 'fixtures', 'computer_says_no.gif') }
      let(:file) { Rack::Test::UploadedFile.new(path_to_file, 'image/gif') }

      it 'returns invalid' do
        expect(subject).to_not be_valid
      end
    end

    context 'when file is blank' do
      let(:path_to_file) { Rails.root.join('spec', 'fixtures', 'empty.csv') }

      it 'returns invalid' do
        expect(subject).to_not be_valid
      end

      it 'returns the correct message' do
        expect(subject.errors.full_messages).to eq([I18n.t(
          'activemodel.errors.models.autocomplete_items.empty'
        )])
      end
    end

    context 'when the file has no headings' do
      let(:path_to_file) { Rails.root.join('spec', 'fixtures', 'invalid.csv') }

      it 'returns invalid' do
        expect(subject).to_not be_valid
      end

      it 'returns the correct message' do
        expect(subject.errors.full_messages).to eq([I18n.t(
          'activemodel.errors.models.autocomplete_items.incorrect_format'
        )])
      end
    end

    context 'when the file has one column' do
      let(:path_to_file) { Rails.root.join('spec', 'fixtures', 'valid_one_column.csv') }

      it 'returns valid' do
        expect(subject).to be_valid
      end
    end

    context 'when a file has more than two columns' do
      let(:path_to_file) { Rails.root.join('spec', 'fixtures', 'three_columns.csv') }

      it 'returns invalid' do
        expect(subject).to_not be_valid
      end
    end

    context 'when a file is malformed' do
      let(:path_to_file) {  Rails.root.join('spec', 'fixtures', 'malformed.csv') }

      it 'throws a malformed csv error' do
        expect(subject.errors.full_messages).to eq([I18n.t(
          'activemodel.errors.models.autocomplete_items.incorrect_format'
        )])
      end
    end

    context 'when file has bom prefix' do
      let(:path_to_file) { Rails.root.join('spec', 'fixtures', 'bom.csv') }

      it 'should be valid' do
        expect(subject).to be_valid
      end
    end
  end
end
