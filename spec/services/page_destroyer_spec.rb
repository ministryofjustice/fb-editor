RSpec.describe PageDestroyer do
  subject(:page) { described_class.new(attributes) }
  let(:service_id) { fixture['service_id'] }
  let(:fixture) { metadata_fixture(:version) }
  let(:version) do
    double(errors?: false, errors: [], metadata: updated_metadata)
  end
  let(:attributes) do
    {
      uuid:,
      service_id:,
      latest_metadata: fixture
    }
  end

  before do
    expect(
      MetadataApiClient::Version
    ).to receive(:create).with(
      service_id:,
      payload: updated_metadata
    ).and_return(version)
  end

  describe '#destroy' do
    context 'when deleting start page' do
      let(:updated_metadata) do
        fixture.deep_dup
      end
      let(:uuid) do
        fixture['pages'][0]['_uuid']
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
        let(:uuid) { page_to_delete_uuid }

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
        let(:uuid) { last_page_uuid }

        it 'updates the previous pages default next to empty string' do
          expect(page.destroy).to eq(updated_metadata)
        end
      end

      context 'page is pointing to itself' do
        let(:uuid) { '2ef7d11e-0307-49e9-9fe2-345dc528dd66' }
        let(:last_page_uuid) { '80420693-d6f2-4fce-a860-777ca774a6f5' }
        let(:fixture) do
          meta = metadata_fixture(:version)
          meta['flow'][uuid]['next']['default'] = uuid
          meta
        end
        let(:updated_metadata) do
          metadata = fixture.deep_dup
          page_index = metadata['pages'].find_index do |page|
            page['_uuid'] == uuid
          end
          metadata['pages'].delete_at(page_index)
          metadata['flow'].delete(uuid)
          metadata['flow'][last_page_uuid]['next']['default'] = ''
          metadata
        end

        it 'updates the next page to empty string' do
          expect(page.destroy).to eq(updated_metadata)
        end
      end
    end

    context 'when deleting a page after a branch condition' do
      let(:service_metadata) { metadata_fixture(:branching_2) }
      let(:fixture) { service_metadata }
      let(:uuid) { service.find_page_by_url('page-c').uuid }
      let(:next_page_uuid_after_the_deleted_page) do
        service.find_page_by_url('page-d').uuid
      end
      let(:updated_metadata) do
        metadata = service_metadata.deep_dup
        metadata['pages'].delete_at(2)
        metadata['flow'].delete(uuid)
        metadata['flow']['09e91fd9-7a46-4840-adbc-244d545cfef7']['next']['conditionals'][0]['next'] = next_page_uuid_after_the_deleted_page
        metadata
      end

      it 'updates all objects to points to what deleted page is pointing to' do
        expect(page.destroy).to eq(updated_metadata)
      end
    end

    # In future, we may not want to allow users to delete Privacy, Accessibility or Cookies standalone pages
    context 'when deleting standalone pages' do
      let(:updated_metadata) do
        metadata = fixture.deep_dup
        metadata['standalone_pages'].delete_at(1)
        metadata
      end
      let(:uuid) { fixture['standalone_pages'][1]['_uuid'] }

      it 'creates new version with page deleted' do
        expect(page.destroy).to eq(updated_metadata)
      end

      it 'does not remove anything from the service flow' do
        expect(page.destroy['flow'].size).to eq(fixture['flow'].size)
      end
    end
  end
end
