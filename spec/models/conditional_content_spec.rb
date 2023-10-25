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
    service.find_page_by_url('conditional-content')
  end
  let(:component_uuid) { 'b872d971-28eb-4aca-826a-5a44d52cead5' }
  let(:latest_metadata) { metadata_fixture(:conditional_content_2) }
  let(:component_json) do
    '{
      "display": "conditional",
      "conditionals": [
        {
          "_uuid":"c3b3fd2d-fe70-464d-9cf1-8ea174676aea",
          "_type":"if",
          "expressions":[
            {
              "operator":"is",
              "page":"bd365ada-2a2a-47b6-a04e-874e300e7b03",
              "component":"8bfde8c8-3075-4879-b3b1-aea875915da9",
              "field":"b0cc81fe-06e2-44d0-94a1-37766027b212"
            }
          ]
        },
        {
          "_uuid":"34923068-c0e9-4f50-a6dc-663a992f71f5",
          "_type":"if",
          "expressions":[
            {
              "operator":"is",
              "page":"3df5937c-8e6e-4e4e-8108-c3b62ad8c91a",
              "component":"9e898dd1-2811-46b8-8fc2-ccc89e24a187",
              "field":"fbbe3268-2523-425e-ad25-955114d90021"
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
                'field' => 'b0cc81fe-06e2-44d0-94a1-37766027b212',
                'operator' => 'is',
                'component' => '8bfde8c8-3075-4879-b3b1-aea875915da9'
              }
            }
          },
          '1' => {
            'expressions_attributes' => {
              '0' => {
                'field' => 'fbbe3268-2523-425e-ad25-955114d90021',
                'operator' => 'is',
                'component' => '9e898dd1-2811-46b8-8fc2-ccc89e24a187'
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
                'field' => 'b0cc81fe-06e2-44d0-94a1-37766027b212',
                'operator' => 'is',
                'component' => '8bfde8c8-3075-4879-b3b1-aea875915da9'
              }
            }
          },
          '1' => {
            'expressions_attributes' => {
              '0' => {
                'field' => 'fbbe3268-2523-425e-ad25-955114d90021',
                'operator' => 'is',
                'component' => '9e898dd1-2811-46b8-8fc2-ccc89e24a187'
              }
            }
          }
        },
        'display' => 'conditional'
      }
    end

    it 'seriualizes the component metadata from json' do
      expect(ConditionalContent.from_json(component_json)).to eq(expected_metadata)
    end
  end

  describe '#previous_questions' do
    it 'returns all questions for single and mulitiple questions pages' do
      skip('Conditional content presenter update') unless ENV['CONDITIONAL_CONTENT'] == 'enabled'
      expect(conditional_content.previous_questions.map { |question| question[0] }).to eq(
        [
          'What is your name?',
          'Do you like chocolate?',
          'Do you like marmite?',
          'Do you like coffee?',
          'What is your favourite cheese?',
          'Choose your top 3 crisp flavours',
          'Which is the best sweet?',
          'What do you put in your coffee?'
        ]
      )
    end

    it 'injects the data-supports-branching attribute' do
      skip('Conditional content presenter update') unless ENV['CONDITIONAL_CONTENT'] == 'enabled'
      expect(conditional_content.previous_questions.map { |question| question[2] }).to eq(
        [
          { 'data-supports-branching': false, 'data-same-page': false },
          { 'data-supports-branching': true, 'data-same-page': false },
          { 'data-supports-branching': true, 'data-same-page': false },
          { 'data-supports-branching': true, 'data-same-page': false },
          { 'data-supports-branching': true, 'data-same-page': false },
          { 'data-supports-branching': true, 'data-same-page': false },
          { 'data-supports-branching': true, 'data-same-page': false },
          { 'data-supports-branching': true, 'data-same-page': false }
        ]
      )
    end

    context 'content component on same page' do
      let(:current_page) do
        service.find_page_by_url('multiple')
      end
      let(:component_uuid) { 'e03e5c74-f719-4310-ab04-0705357cb159' }

      it 'injects the data-same-page attribute' do
        skip('Conditional content presenter update') unless ENV['CONDITIONAL_CONTENT'] == 'enabled'
        expect(conditional_content.previous_questions.map { |question| question[2] }).to eq(
          [
            { 'data-supports-branching': false, 'data-same-page': false },
            { 'data-supports-branching': true, 'data-same-page': false },
            { 'data-supports-branching': true, 'data-same-page': false },
            { 'data-supports-branching': true, 'data-same-page': false },
            { 'data-supports-branching': true, 'data-same-page': true },
            { 'data-supports-branching': true, 'data-same-page': true },
            { 'data-supports-branching': true, 'data-same-page': true },
            { 'data-supports-branching': true, 'data-same-page': false }
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
                  'field' => 'b4053846-9e8c-4d0f-baae-f88a4a919fdb',
                  'operator' => 'is_not',
                  'component' => 'aa895578-c9fc-48e8-ac71-802d7cf61cca',
                  'page' => previous_page
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
