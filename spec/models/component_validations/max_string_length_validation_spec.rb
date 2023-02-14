RSpec.describe 'MaxStringLengthValidation' do
  let(:subject) { MaxStringLengthValidation.new(validation_params) }
  let(:latest_metadata) { metadata_fixture(:version) }
  let(:service) { MetadataPresenter::Service.new(latest_metadata) }
  let(:validation_params) do
    {
      service:,
      page_uuid:,
      component_uuid:,
      validator:,
      status:,
      value:,
      string_length:
    }
  end
  let(:page_uuid) { 'e8708909-922e-4eaf-87a5-096f7a713fcb' } # how well do you know star wars?
  let(:component_uuid) { 'fda1e5a1-ed5f-49c9-a943-dc930a520984' }
  let(:validator) { 'max_string_length' }
  let(:status) { 'enabled' }
  let(:value) { '50' }
  let(:string_length) { 'max_length' }
  let(:expected_number_error) { 'Maximum answer length needs to be a number' }
  let(:expected_blank_error) { 'Enter an answer for Maximum answer length' }

  it_behaves_like 'a base component validation'
  it_behaves_like 'a number validation'
  it_behaves_like 'a string length validation'

  describe '#to_metadata' do
    context 'when validator is max_length' do
      let(:expected_metadata) { { 'max_length' => '50' } }

      it 'returns default metadata' do
        expect(subject.to_metadata).to eq(expected_metadata)
      end
    end

    context 'when validator is max_word' do
      let(:string_length) { 'max_word' }
      let(:expected_metadata) { { 'max_word' => '50' } }

      it 'returns default metadata' do
        expect(subject.to_metadata).to eq(expected_metadata)
      end
    end

    context 'when setting a new value for previously configured validation' do
      let(:page_uuid) { '9e1ba77f-f1e5-42f4-b090-437aa9af7f73' } # name
      let(:component_uuid) { '27d377a2-6828-44ca-87d1-b83ddac98284' }
      let(:value) { '5000' }
      let(:expected_metadata) { { 'max_length' => '5000' } }

      it 'returns the new value' do
        expect(subject.to_metadata).to eq(expected_metadata)
      end
    end

    context 'when status is not enabled' do
      let(:status) { nil }
      let(:expected_metadata) do
        {
          'max_length' => '',
          'max_word' => ''
        }
      end

      it 'returns both string length validations with empty strings' do
        expect(subject.to_metadata).to eq(expected_metadata)
      end
    end

    context 'when other maximum string validation has been configured' do
      let(:page_uuid) { '9e1ba77f-f1e5-42f4-b090-437aa9af7f73' } # name
      let(:component_uuid) { '27d377a2-6828-44ca-87d1-b83ddac98284' }
      let(:string_length) { 'max_word' }
      let(:expected_metadata) do
        {
          'max_word' => value,
          'max_length' => ''
        }
      end

      it 'returns the correct metadata with both keys' do
        expect(subject.to_metadata).to eq(expected_metadata)
      end
    end
  end
end
