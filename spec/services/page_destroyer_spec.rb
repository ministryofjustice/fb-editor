RSpec.describe PageDestroyer do
  subject(:page) { described_class.new(attributes) }
  let(:service_id) { fixture['service_id'] }
  let(:fixture) { metadata_fixture(:version) }
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
        fixture.deep_dup
      end
      let(:attributes) do
        {
          uuid: fixture['pages'][0]['_uuid'],
          service_id: service_id,
          latest_metadata: fixture
        }
      end
      before do
        expect(
          MetadataApiClient::Version
        ).to_not receive(:create)
      end

      it 'does not delete the start page from the pages array or the service flow' do
        expect(page.destroy).to eq(updated_metadata)
      end
    end

    context 'when deleting other flow pages' do
      context 'page is in the middle of a flow' do
        let(:start_page_uuid) { fixture['pages'][0]['_uuid'] }
        let(:page_to_delete_uuid) { fixture['pages'][1]['_uuid'] }
        let(:third_page_uuid) { fixture['pages'][2]['_uuid'] }
        let(:updated_metadata) do
          metadata = fixture.deep_dup
          metadata['pages'].delete_at(1)
          metadata['flow'].delete(page_to_delete_uuid)
          metadata['flow'][start_page_uuid]['next']['default'] = third_page_uuid
          metadata
        end
        let(:attributes) do
          {
            uuid: page_to_delete_uuid,
            service_id: service_id,
            latest_metadata: fixture
          }
        end

        it 'creates new version with page deleted and the page flow object deleted' do
          expect(page.destroy).to eq(updated_metadata)
        end

        it 'updates the reference to the deleted page to point at the next page in the flow' do
          start_page_flow = page.destroy['flow'][start_page_uuid]
          expect(start_page_flow['next']['default']).to eq(third_page_uuid)
        end
      end

      context 'page is the last page in the service flow' do
        let(:last_page_uuid) { fixture['pages'].last['_uuid'] }
        let(:check_answers_uuid) { fixture['pages'][-2]['_uuid'] }
        let(:updated_metadata) do
          metadata = fixture.deep_dup
          metadata['pages'].pop
          metadata['flow'].delete(last_page_uuid)
          metadata['flow'][check_answers_uuid]['next']['default'] = ''
          metadata
        end
        let(:attributes) do
          {
            uuid: last_page_uuid,
            service_id: service_id,
            latest_metadata: fixture
          }
        end

        it 'updates the previous pages default next to empty string' do
          expect(page.destroy).to eq(updated_metadata)
        end
      end
    end

    # In future, we may not want to allow users to delete Privacy, Accessibility or Cookies standalone pages
    context 'when deleting standalone pages' do
      let(:updated_metadata) do
        metadata = fixture.deep_dup
        metadata['standalone_pages'].delete_at(1)
        metadata
      end
      let(:attributes) do
        {
          uuid: fixture['standalone_pages'][1]['_uuid'],
          service_id: service_id,
          latest_metadata: fixture
        }
      end

      it 'creates new version with page deleted' do
        expect(page.destroy).to eq(updated_metadata)
      end

      it 'does not remove anything from the service flow' do
        expect(page.destroy['flow'].size).to eq(fixture['flow'].size)
      end
    end
  end
end
