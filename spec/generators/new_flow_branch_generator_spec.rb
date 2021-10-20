RSpec.describe NewFlowBranchGenerator do
  subject(:generator) { described_class.new(attributes) }
  let(:latest_metadata) { metadata_fixture('branching') }
  let(:valid) { true }

  context 'creating a new branching object' do
    let(:conditional) do
      object = Conditional.new('next' => 'another-page-uuid')
      object.tap do
        object.expressions.push(Expression.new(expression))
      end
    end
    let(:expression) do
      {
        operator: 'is',
        page: double(uuid: 'expression-page-uuid'),
        component: 'component-uuid',
        field: 'field-uuid'
      }
    end
    let(:attributes) do
      {
        default_next: 'default-next-uuid',
        conditionals: [conditional]
      }
    end

    context 'in the middle of a flow' do
      let(:uuid) { 'new-branch-uuid' }
      let(:expected_metadata) do
        {
          uuid => {
            '_type' => 'flow.branch',
            'title' => '',
            'next' => {
              'default' => 'default-next-uuid',
              'conditionals' => [
                '_uuid' => 'you-can-do-it',
                '_type' => 'if',
                'next' => 'another-page-uuid',
                'expressions' => [
                  {
                    'operator' => 'is',
                    'page' => 'expression-page-uuid',
                    'component' => 'component-uuid',
                    'field' => 'field-uuid'
                  }
                ]
              ]
            }
          }
        }
      end

      before do
        allow(SecureRandom).to receive(:uuid).and_return(uuid)
        allow(conditional).to receive(
          :generate_uuid
        ).and_return('you-can-do-it')
      end

      it 'creates valid flow branch object metadata' do
        expect(
          MetadataPresenter::ValidateSchema.validate(
            generator.to_metadata, 'flow.base'
          )
        ).to be(valid)
      end

      it 'creates the correct conditional metadata' do
        expect(generator.to_metadata).to eq(expected_metadata)
      end
    end
  end
end
