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
    service.find_page_by_url('multiple')
  end
  let(:previous_flow_uuid) do
    previous_page.uuid
  end
  let(:current_page) do
    service.find_page_by_url('best-content')
  end
  let(:component_uuid) { 'f7208ed7-ed10-4c53-9271-ab075f6d3e3c' }
  let(:latest_metadata) { metadata_fixture(:conditional) }
  let(:component_json) do
    '{
      "display": "conditional",
      "conditionals": [
        {
          "_uuid":"6b1dea31-abbd-4053-8e6f-6211534dcd3b",
          "_type":"if",
          "expressions":[
            {
              "operator":"is",
              "page":"00cc353e-51c5-4462-88bc-c357e344cd4d",
              "component":"db99d122-17e4-47b1-b5a4-d6e8bf70fa86",
              "field":"38492ffc-b18c-4b0b-94fe-c1addd854738"
            }
          ]
        },
        {
          "_uuid":"291df640-16b0-4b7d-876e-92662d95e7a5",
          "_type":"if",
          "expressions":[
            {
              "operator":"is",
              "page":"00cc353e-51c5-4462-88bc-c357e344cd4d",
              "component":"db99d122-17e4-47b1-b5a4-d6e8bf70fa86",
              "field":"f0c1585e-7b23-461a-8644-4da3b2e1ebc4"
            }
          ]
        }
      ]
    }'
  end
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
                'field' => '38492ffc-b18c-4b0b-94fe-c1addd854738',
                'operator' => 'is',
                'component' => 'db99d122-17e4-47b1-b5a4-d6e8bf70fa86'
              }
            }
          },
          '1' => {
            'expressions_attributes' => {
              '0' => {
                'field' => 'f0c1585e-7b23-461a-8644-4da3b2e1ebc4',
                'operator' => 'is',
                'component' => 'db99d122-17e4-47b1-b5a4-d6e8bf70fa86'
              }
            }
          }
        },
        'display' => 'conditional'
      }
    end

    it 'serialises the component objects metadata' do
      skip('Conditional content presenter update') unless ENV['CONDITIONAL_CONTENT'] == 'enabled'
      expect(ConditionalContent.from_metadata(component)).to eq(expected_metadata)
    end
  end

  describe '.from_json' do
    skip('Conditional content presenter update') unless ENV['CONDITIONAL_CONTENT'] == 'enabled'
    let(:component) do
      current_page.find_component_by_uuid(component_uuid)
    end
    let(:expected_metadata) do
      {
        'conditionals_attributes' => {
          '0' => {
            'expressions_attributes' => {
              '0' => {
                'field' => '38492ffc-b18c-4b0b-94fe-c1addd854738',
                'operator' => 'is',
                'component' => 'db99d122-17e4-47b1-b5a4-d6e8bf70fa86'
              }
            }
          },
          '1' => {
            'expressions_attributes' => {
              '0' => {
                'field' => 'f0c1585e-7b23-461a-8644-4da3b2e1ebc4',
                'operator' => 'is',
                'component' => 'db99d122-17e4-47b1-b5a4-d6e8bf70fa86'
              }
            }
          }
        },
        'display' => 'conditional'
      }
    end

    it 'seriualizes the component metadat from json' do
      expect(ConditionalContent.from_json(component_json)).to eq(expected_metadata)
    end
  end

  describe '#previous_questions' do
    it 'returns all questions for single and mulitiple questions pages' do
      skip('Conditional content presenter update') unless ENV['CONDITIONAL_CONTENT'] == 'enabled'
      expect(conditional_content.previous_questions.map { |question| question[0] }).to eq(
        [
          'Single Radios',
          'radio',
          'checkbox (optional)',
          'name'
        ]
      )
    end

    it 'injects the data-supports-branching attribute' do
      skip('Conditional content presenter update') unless ENV['CONDITIONAL_CONTENT'] == 'enabled'
      expect(conditional_content.previous_questions.map { |question| question[2] }).to eq(
        [
          { 'data-supports-branching': true, 'data-same-page': false },
          { 'data-supports-branching': true, 'data-same-page': false },
          { 'data-supports-branching': true, 'data-same-page': false },
          { 'data-supports-branching': false, 'data-same-page': false }
        ]
      )
    end

    context 'content component on same page' do
      let(:current_page) do
        service.find_page_by_url('multiple')
      end
      let(:component_uuid) { '73869807-f82f-4000-8204-fcb3f62718a2' }

      it 'injects the data-same-page attribute' do
        skip('Conditional content presenter update') unless ENV['CONDITIONAL_CONTENT'] == 'enabled'
        expect(conditional_content.previous_questions.map { |question| question[2] }).to eq(
          [
            { 'data-supports-branching': true, 'data-same-page': false },
            { 'data-supports-branching': true, 'data-same-page': true },
            { 'data-supports-branching': true, 'data-same-page': true },
            { 'data-supports-branching': false, 'data-same-page': true }
          ]
        )
      end
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
      skip('Conditional content presenter update') unless ENV['CONDITIONAL_CONTENT'] == 'enabled'
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
        skip('Conditional content presenter update') unless ENV['CONDITIONAL_CONTENT'] == 'enabled'
        expect(conditional_content.flow_uuid).to eq(previous_flow_uuid)
      end
    end

    context 'there is no previous page' do
      let(:previous_flow_uuid) { nil }

      it 'returns the current page in the flow' do
        skip('Conditional content presenter update') unless ENV['CONDITIONAL_CONTENT'] == 'enabled'
        expect(conditional_content.flow_uuid).to eq(current_page[:_uuid])
      end
    end
  end

  describe '#validations' do
    skip('Conditional content presenter update') unless ENV['CONDITIONAL_CONTENT'] == 'enabled'
    before do
      conditional_content.valid? if ENV['CONDITIONAL_CONTENT'] == 'enabled'
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
        skip('Conditional content presenter update') unless ENV['CONDITIONAL_CONTENT'] == 'enabled'
        expect(conditional_content.conditionals_validations).to be_present
      end

      it 'adds error to conditionals object' do
        skip('Conditional content presenter update') unless ENV['CONDITIONAL_CONTENT'] == 'enabled'
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
                  'field' => '63dce510-a641-4649-906c-334262c37673',
                  'operator' => 'is_not',
                  'component' => 'db99d122-17e4-47b1-b5a4-d6e8bf70fa86'
                }
              }
            }
          }
        }
      end

      it 'no errors on conditional_content' do
        skip('Conditional content presenter update') unless ENV['CONDITIONAL_CONTENT'] == 'enabled'
        expect(conditional_content.errors).to be_blank
      end

      it 'no errors on conditionals' do
        skip('Conditional content presenter update') unless ENV['CONDITIONAL_CONTENT'] == 'enabled'
        errors = conditional_content.conditionals.first.errors
        expect(errors).to be_blank
      end
    end
  end
end
