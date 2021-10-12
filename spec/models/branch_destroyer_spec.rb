RSpec.describe BranchDestroyer do
  subject(:branch_destroyer) do
    described_class.new(
      service: service,
      branch_uuid: branch_uuid
    )
  end
  let(:service_metadata) { metadata_fixture(:branching_2) }
  let(:branch_uuid) { '09e91fd9-7a46-4840-adbc-244d545cfef7' }

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
end
