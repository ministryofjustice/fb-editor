RSpec.describe PageDestroyer do
  subject(:page) { described_class.new(attributes) }
  let(:service_id) { service.service_id }
  let(:version) do
    double(errors?: false, errors: [], metadata: updated_metadata)
  end

  before do
    expect(
      MetadataApiClient::Version
    ).to receive(:create).with(
      service_id: service_id,
      payload: updated_metadata
    ).and_return(version)
  end

  describe '#destroy' do
    context 'when deleting start page' do
      let(:updated_metadata) do
        service_metadata.deep_dup
      end
      let(:attributes) do
        {
          uuid: service_metadata['pages'][0]['_uuid'],
          service_id: service.service_id,
          latest_metadata: service_metadata
        }
      end
      before do
        expect(
          MetadataApiClient::Version
        ).to_not receive(:create)
      end

      it 'creates new version with start page' do
        expect(page.destroy).to eq(updated_metadata)
      end
    end

    context 'when deleting other flow pages' do
      let(:updated_metadata) do
        metadata = service_metadata.deep_dup
        metadata['pages'].delete_at(1)
        metadata['pages'][0]['steps'].delete('page.name')
        metadata
      end
      let(:attributes) do
        {
          uuid: '9e1ba77f-f1e5-42f4-b090-437aa9af7f73',
          service_id: service.service_id,
          latest_metadata: service_metadata
        }
      end

      it 'creates new version with page deleted' do
        expect(page.destroy).to eq(updated_metadata)
      end
    end

    # In future, we may not want to allow users to delete Privacy, Accessibility or Cookies standalone pages
    context 'when deleting standalone pages' do
      let(:updated_metadata) do
        metadata = service_metadata.deep_dup
        metadata['standalone_pages'].delete_at(1)
        metadata
      end
      let(:attributes) do
        {
          uuid: '4b86fe8c-7723-4cce-9378-7b2510279e04',
          service_id: service.service_id,
          latest_metadata: service_metadata
        }
      end

      it 'creates new version with page deleted' do
        expect(page.destroy).to eq(updated_metadata)
      end
    end
  end
end
