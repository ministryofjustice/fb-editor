RSpec.describe NumberValidator do
  let(:subject) { DateBeforeValidation.new(validation_params) }
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
  let(:validator) { 'date_before' }
  let(:status) { 'enabled' }
  let(:day) { '1' }
  let(:month) { '1' }
  let(:year) { '2001' }

  describe '#validate' do
    before { subject.validate }

    context 'when a valid date' do
      it 'returns valid' do
        expect(subject).to be_valid
      end
    end

    context 'when not a date' do
      let(:day) { 'not a day' }

      it 'returns invalid' do
        expect(subject).to_not be_valid
      end
    end
  end
end
