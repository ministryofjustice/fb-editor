RSpec.describe ConditionalContent do
  subject(:conditional_content) do
    described_class.new(conditional_content_attributes)
  end
  let(:attributes) { {} }
  let(:conditional_content_attributes) do
    {
      service:,
      previous_flow_uuid:,
      component_uuid:
    }.merge(attributes)
  end
  let(:previous_page) do
    service.find_page_by_url('pets')
  end
  let(:previous_flow_uuid) do
    previous_page.uuid
  end
  let(:current_page) do
    service.find_page_by_url('furry')
  end
  let(:component_uuid) { '46a49bb2-349d-47f2-bb75-eaed3892d5d7' }
  let(:latest_metadata) { metadata_fixture(:conditional) }
  let(:service) do
    MetadataPresenter::Service.new(latest_metadata)
  end

  describe '.from_metadata' do
    let(:component) do
      current_page.find_component_by_uuid(component_uuid)
    end
    let(:expected_metadata) do
      {
        'conditionals_attributes' => {
          '0' => {
            'expressions_attributes' => {
              '0' => {
                'page' => '07635f6d-34a8-45c8-884f-87696eba6a1f',
                'field' => '46c218d5-018a-482a-a66d-0d84be80f543',
                'operator' => 'is_not',
                'component' => '612f5bc2-8766-4296-9b9c-47f92bdc4b62'
              }
            }
          }
        },
        'display' => nil
      }
    end

    it 'serialises the component objects metadata' do
      pending('Conditional content presenter update') unless ENV['CONDITONAL_CONTENT'] == 'enabled'
      expect(ConditionalContent.from_metadata(component)).to eq(expected_metadata)
    end
  end

  describe '.from_json' do
  end

  describe '#previous_questions' do
    it 'returns all questions for single and mulitiple questions pages' do
      pending('Conditional content presenter update') unless ENV['CONDITONAL_CONTENT'] == 'enabled'
      expect(conditional_content.previous_questions.map { |question| question[0] }).to eq(
        [
          'Checkbox',
          'Colours',
          'Pet choice',
          'Email address question'
        ]
      )
    end

    it 'injects the data-supports-branching attribute' do
      pending('Conditional content presenter update') unless ENV['CONDITONAL_CONTENT'] == 'enabled'
      expect(conditional_content.previous_questions.map { |question| question[2] }).to eq(
        [
          { 'data-supports-branching': true },
          { 'data-supports-branching': true },
          { 'data-supports-branching': true },
          { 'data-supports-branching': false }
        ]
      )
    end
  end

  describe '#conditional_attributes=' do
    let(:attributes) do
      {
        'conditionals_attributes' => {
          '0' => {
            'expressions_attributes' => {
              '0' => { 'component' => 'd1c04d9e-877f-4219-a96f-e21dde925f4b' }
            }
          }
        }
      }
    end
    let(:expected_conditional) do
      object = ComponentConditional.new(
        'service' => service
      )
      object.tap do
        object.expressions.push(
          ComponentExpression.new(
            'component' => 'd1c04d9e-877f-4219-a96f-e21dde925f4b',
            'page' => double(uuid: 'some-page-uuid')
          )
        )
      end
    end

    it 'assigns conditionals' do
      pending('Conditional content presenter update') unless ENV['CONDITONAL_CONTENT'] == 'enabled'
      expect(conditional_content.conditionals).to eq(
        [
          expected_conditional
        ]
      )
    end
  end

  describe '#previous_flow_uuid' do
    context 'previous flow uuid is present' do
      it 'returns the previous flow uuid' do
        pending('Conditional content presenter update') unless ENV['CONDITONAL_CONTENT'] == 'enabled'
        expect(conditional_content.flow_uuid).to eq(previous_flow_uuid)
      end
    end

    context 'there is no previous page' do
      let(:previous_flow_uuid) { nil }

      it 'returns the current page in the flow' do
        pending('Conditional content presenter update') unless ENV['CONDITONAL_CONTENT'] == 'enabled'
        expect(conditional_content.flow_uuid).to eq(current_page[:_uuid])
      end
    end
  end

  describe '#validations' do
    skip('Conditional content presenter update') unless ENV['CONDITONAL_CONTENT'] == 'enabled'
    before do
      conditional_content.valid? if ENV['CONDITONAL_CONTENT'] == 'enabled'
    end

    context 'when blank conditionals' do
      let(:attributes) do
        {
          'conditionals_attributes' => {
            '0' => {
              'expressions_attributes' => {
                '0' => { 'component' => '' }
              }
            }
          }
        }
      end

      it 'does not accept blank conditionals' do
        skip('Conditional content presenter update') unless ENV['CONDITONAL_CONTENT'] == 'enabled'
        expect(conditional_content.conditionals_validations).to be_present
      end

      it 'adds error to conditionals object' do
        skip('Conditional content presenter update') unless ENV['CONDITONAL_CONTENT'] == 'enabled'
        errors = conditional_content.conditionals.first.errors
        expect(errors).to be_present
        expect(errors.of_kind?(:expressions, :invalid_expression)).to be_truthy
      end
    end

    context 'when valid conditionals' do
      let(:attributes) do
        {
          'conditionals_attributes' => {
            '0' => {
              'expressions_attributes' => {
                '0' => {
                  'page' => '07635f6d-34a8-45c8-884f-87696eba6a1f',
                  'field' => '46c218d5-018a-482a-a66d-0d84be80f543',
                  'operator' => 'is_not',
                  'component' => '612f5bc2-8766-4296-9b9c-47f92bdc4b62'
                }
              }
            }
          }
        }
      end

      it 'no errors on conditional_content' do
        skip('Conditional content presenter update') unless ENV['CONDITONAL_CONTENT'] == 'enabled'
        expect(conditional_content.errors).to be_blank
      end

      it 'no errors on conditionals' do
        skip('Conditional content presenter update') unless ENV['CONDITONAL_CONTENT'] == 'enabled'
        errors = conditional_content.conditionals.first.errors
        expect(errors).to be_blank
      end
    end
  end
end
