RSpec.describe Route do
  subject(:route) do
    described_class.new(service: service, traverse_from: traverse_from)
  end

  before do
    route.traverse
  end

  describe '#traverse' do
    let(:metadata) { metadata_fixture(:branching) }
    let(:service) { MetadataPresenter::Service.new(metadata) }

    context 'when traversing from the start' do
      let(:traverse_from) { service.start_page.uuid }
      let(:potential_routes) do
        # total number of all conditional next's and the default_next
        # for the first branch that is found
        2
      end
      let(:expected_uuids) do
        [
          'cf6dc32f-502c-4215-8c27-1151a45735bb', # includes the start page
          '9e1ba77f-f1e5-42f4-b090-437aa9af7f73',
          '68fbb180-9a2a-48f6-9da6-545e28b8d35a'
        ]
      end

      it 'should return the page uuids for all traversed pages' do
        expect(route.page_uuids).to eq(expected_uuids)
      end

      it 'should return a route object for each possible conditional next' do
        expect(route.routes.size).to eq(potential_routes)
      end
    end

    context 'when traversing from the middle' do
      let(:traverse_from) { service.find_page_by_url('favourite-fruit').uuid }
      let(:potential_routes) { 3 }
      let(:expected_uuids) { %w[0b297048-aa4d-49b6-ac74-18e069118185] }

      it 'should return the page uuids for all traversed pages' do
        expect(route.page_uuids).to eq(expected_uuids)
      end

      it 'should return a route object for each possible conditional next' do
        expect(route.routes.size).to eq(potential_routes)
      end
    end
  end
end
