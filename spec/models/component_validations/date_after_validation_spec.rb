RSpec.describe DateAfterValidation do
  let(:subject) { DateAfterValidation.new(validation_params) }
  let(:latest_metadata) { metadata_fixture(:version) }
  let(:service) { MetadataPresenter::Service.new(latest_metadata) }
  let(:validation_params) do
    {
      service:,
      page_uuid:,
      component_uuid:,
      validator:,
      status:,
      day:,
      month:,
      year:
    }
  end
  let(:page_uuid) { '7806cd64-0c05-450e-ba6f-2325c8b22d46' } # holiday
  let(:component_uuid) { 'f16b7e7b-fbfa-4e41-a413-ee7eaf6063a6' }
  let(:validator) { 'date_after' }
  let(:status) { 'enabled' }
  let(:day) { '30' }
  let(:month) { '3' }
  let(:year) { '1964' }
  let(:component_validation) { { 'date_after' => '1066-12-21' } }
  let(:previously_set_fields) do
    {
      'day' => 21,
      'month' => 12,
      'year' => 1066
    }
  end

  it_behaves_like 'a date validation'

  describe '#to_metadata' do
    let(:expected_metadata) { { 'date_after' => '1964-03-30' } }

    it 'returns default metadata' do
      expect(subject.to_metadata).to eq(expected_metadata)
    end
  end
end
