RSpec.describe 'PatternValidation' do
  let(:subject) { PatternValidation.new(validation_params) }
  let(:latest_metadata) { metadata_fixture(:version) }
  let(:service) { MetadataPresenter::Service.new(latest_metadata) }
  let(:validation_params) do
    {
      service:,
      page_uuid:,
      component_uuid:,
      validator:,
      status:,
      value:
    }
  end

  let(:page_uuid) { 'e8708909-922e-4eaf-87a5-096f7a713fcb' } # how well do you know star wars?
  let(:component_uuid) { 'fda1e5a1-ed5f-49c9-a943-dc930a520984' }
  let(:validator) { 'pattern' }
  let(:status) { 'enabled' }
  let(:expected_blank_error) { 'Enter a regular expression' }
  let(:value) { '\w+' }

  it_behaves_like 'a base component validation'

  describe '#main_value' do
    context 'when value is present' do
      let(:value) { '\d+' }

      it 'returns the value initialised in the model' do
        expect(subject.main_value).to eq(value)
      end
    end
  end

  describe '#to_metadata' do
    let(:value) { '\d+' }
    let(:expected_metadata) { { 'pattern' => value } }

    it 'returns default metadata' do
      expect(subject.to_metadata).to eq(expected_metadata)
    end
  end

  context '#valid when there are no value provided for regex' do
    let(:value) { '' }

    it 'it returns invalid' do
      expect(subject).to be_invalid
    end

    it 'surfaces the error' do
      subject.valid?
      expect(subject.errors.full_messages.first).to eq(expected_blank_error)
    end
  end
end
