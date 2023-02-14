RSpec.describe BranchDestroyer do
  subject(:branch_destroyer) do
    described_class.new(
      service:,
      branch_uuid:,
      destination_uuid:,
      latest_metadata: service_metadata
    )
  end
  let(:service_metadata) { metadata_fixture(:branching_2) }
  let(:branch_uuid) { '09e91fd9-7a46-4840-adbc-244d545cfef7' }
  let(:destination_uuid) { service.find_page_by_url('page-c').uuid }

  describe '#title' do
    it 'returns branch title' do
      expect(branch_destroyer.title).to eq('Branching point 1')
    end
  end

  describe '#previous_page_title' do
    it 'returns previous page title' do
      expect(branch_destroyer.previous_page_title).to eq('Page B')
    end
  end

  describe '#destinations' do
    let(:page_c) { service.find_page_by_url('page-c') }
    let(:page_g) { service.find_page_by_url('page-g') }
    let(:page_j) { service.find_page_by_url('page-j') }

    it 'returns first page of all possible condition routes' do
      expect(branch_destroyer.destinations).to eq([
        page_c, page_g, page_j
      ])
    end
  end

  describe '#destination_uuid' do
    context 'when is present' do
      let(:destination_uuid) do
        service.find_page_by_url('page-j').uuid
      end

      it 'returns uuid' do
        expect(branch_destroyer.destination_uuid).to eq(destination_uuid)
      end
    end

    context 'when is blank' do
      let(:destination_uuid) { nil }

      it 'returns uuid of the first route' do
        expect(branch_destroyer.destination_uuid).to eq(
          service.find_page_by_url('page-c').uuid
        )
      end
    end
  end

  describe '#destroy' do
    it 'creates a new version with branch destroyed' do
      expect(MetadataApiClient::Version).to receive(:create)
        .with(
          service_id: service.service_id,
          payload: branch_destroyer.destroyed_branch_metadata
        )
      branch_destroyer.destroy
    end
  end

  describe '#destroyed_branch_metadata' do
    let(:destroyed_branch_metadata) do
      MetadataPresenter::Service.new(
        branch_destroyer.destroyed_branch_metadata
      )
    end
    let(:flow_object_before_branch) do
      destroyed_branch_metadata
        .flow_object('68fbb180-9a2a-48f6-9da6-545e28b8d35a')
    end

    it 'changes all pages before branch to point to the new destination' do
      expect(flow_object_before_branch.default_next).to eq(destination_uuid)
    end

    it 'removes branch from the flow object' do
      # before deleting
      expect(
        service.flow[branch_uuid]
      ).to_not be_nil

      # after calling the deletion
      expect(
        destroyed_branch_metadata.flow[branch_uuid]
      ).to be_nil
    end
  end
end
