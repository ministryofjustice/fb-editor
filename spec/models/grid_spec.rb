RSpec.describe Grid do
  subject(:grid) { described_class.new(service) }
  let(:latest_metadata) { metadata_fixture(:branching) }
  let(:service) { MetadataPresenter::Service.new(latest_metadata) }

  describe '#ordered_pages' do
    context 'when excluding branches' do
      it 'should not include any branch flow objects' do
        expect(grid.ordered_pages.any? { |flow| flow.type == 'flow.branch' }).to be_falsey
      end
    end
  end

  describe '#ordered_flow' do
    context 'when including branches' do
      it 'should include flow branch objects' do
        expect(grid.ordered_flow.any? { |flow| flow.type == 'flow.branch' }).to be_truthy
      end

      it 'should use the MetadataPresenter::Flow objects' do
        grid.ordered_flow.each do |obj|
          expect(obj).to be_a_kind_of(MetadataPresenter::Flow)
        end
      end
    end
  end
end
