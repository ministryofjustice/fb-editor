RSpec.describe BranchCreation, type: :model do
  subject(:branch_creation) do
    described_class.new(branch: branch, latest_metadata: metadata)
  end
  let(:metadata) { metadata_fixture(:branching) }

  describe '#branch_uuid' do
    let(:uuid) { SecureRandom.uuid }
    let(:branch) { Branch.new(attributes) }
    let(:new_flow_branch_generator) { double(uuid: uuid) }
    before do
      allow(NewFlowBranchGenerator).to receive(:new).and_return(new_flow_branch_generator)
    end
    let(:attributes) { {} }

    it 'should return the uuid of the new flow branch object' do
      expect(branch_creation.branch_uuid).to eq(uuid)
    end
  end

  describe '#metadata' do
    let(:branch) { Branch.new(attributes) }
    let(:default_next) { SecureRandom.uuid }
    let(:previous_flow_object) do
      metadata['pages'].find { |page| page['url'] == 'favourite-fruit' }
    end
    let(:conditionals_attributes) do
      {
        '0' => {
          'next' => 'some-page-uuid',
          'expressions_attributes' => {
            '0' => {
              'operator' => 'is',
              'page' => 'another-page-uuid',
              'component' => 'some-component-uuid',
              'field' => 'some-field-uuid'
            }
          }
        }
      }
    end
    let(:params) do
      {
        branch: {
          flow_uuid: previous_flow_object['_uuid'],
          conditionals_attributes: conditionals_attributes
        }
      }
    end
    let(:attributes) do
      {
        service: service,
        previous_flow_uuid: previous_flow_object['_uuid'],
        conditionals_attributes: conditionals_attributes,
        default_next: default_next
      }
    end

    context 'when metadata is valid' do
      let(:valid) { true }
      let(:flow_object) { branch_creation.metadata['flow'][branch_creation.branch_uuid] }
      let(:expected_conditionals) do
        [
          {
            '_type' => 'if',
            'next' => 'some-page-uuid',
            'expressions' => [
              {
                'operator' => 'is',
                'page' => 'another-page-uuid',
                'component' => 'some-component-uuid',
                'field' => 'some-field-uuid'
              }
            ]
          }
        ]
      end

      it 'creates valid service metadata' do
        expect(
          MetadataPresenter::ValidateSchema.validate(
            branch_creation.metadata, 'service.base'
          )
        ).to be(valid)
      end

      it 'updates the service flow with the correct default next' do
        expect(flow_object['next']['default']).to eq(default_next)
      end

      it 'updates the service flow with the correct conditionals' do
        expect(flow_object['next']['conditionals']).to eq(expected_conditionals)
      end
    end
  end
end
