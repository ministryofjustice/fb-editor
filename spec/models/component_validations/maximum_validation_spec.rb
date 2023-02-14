RSpec.describe 'MaximumValidation' do
  let(:subject) { MaximumValidation.new(validation_params) }
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
  let(:page_uuid) { '54ccc6cd-60c0-4749-947b-a97af1bc0aa2' } # your age
  let(:component_uuid) { 'b3014ef8-546a-4a35-9669-c5c1667e86d7' }
  let(:validator) { 'maximum' }
  let(:status) { 'enabled' }
  let(:value) { '5' }
  let(:expected_number_error) { 'Maximum answer value needs to be a number' }
  let(:expected_blank_error) { 'Enter an answer for Maximum answer value' }

  it_behaves_like 'a base component validation'
  it_behaves_like 'a number validation'

  describe '#to_metadata' do
    let(:expected_metadata) { { 'maximum' => '5' } }

    it 'returns default metadata' do
      expect(subject.to_metadata).to eq(expected_metadata)
    end
  end
end
