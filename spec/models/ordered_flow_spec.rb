RSpec.describe OrderedFlow do
  subject(:ordered_flow) do
    described_class.new(arguments.merge(service: service))
  end
  let(:latest_metadata) { metadata_fixture(:branching) }
  let(:service) { MetadataPresenter::Service.new(latest_metadata) }

  describe '#build' do
    context 'when building the pages flow' do
      let(:arguments) { { pages_flow: true } }

      it 'adds FlowStack objects' do
        ordered_flow.build.each do |obj|
          expect(obj).to be_a_kind_of(FlowStack)
        end
      end
    end

    context 'when excluding branches' do
      let(:arguments) { { exclude_branches: true } }

      it 'should not include any branch flow objects' do
        expect(ordered_flow.build.any? { |flow| flow.type == 'flow.branch' }).to be_falsey
      end
    end

    context 'when not building the pages flow or excluding branches' do
      let(:arguments) { {} }

      it 'should include flow branch objects' do
        expect(ordered_flow.build.any? { |flow| flow.type == 'flow.branch' }).to be_truthy
      end

      it 'should use the MetadataPresenter::Flow objects' do
        ordered_flow.build.each do |obj|
          expect(obj).to be_a_kind_of(MetadataPresenter::Flow)
        end
      end
    end
  end
end
