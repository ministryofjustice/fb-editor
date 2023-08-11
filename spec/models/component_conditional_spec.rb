RSpec.describe ComponentConditional do
  subject(:component_conditional) do
    described_class.new(component_conditional_hash)
  end
  let(:component_conditional_hash) do
    {
      'expressions' => [
        ComponentExpression.new(
          {
            'operator' => 'is',
            'component' => '67890',
            'page' => double(uuid: 'some-page-uuid'),
            'field' => 'some-field-uuid'
          }
        )
      ]
    }.merge(service:)
  end
  let(:expected_component_conditional) do
    {
      '_uuid' => 'til-its-done',
      '_type' => 'if',
      'expressions' => [
        {
          'operator' => 'is',
          'component' => '67890',
          'page' => 'some-page-uuid',
          'field' => 'some-field-uuid'
        }
      ]
    }
  end

  describe '#to_metadata' do
    before do
      allow(component_conditional).to receive(:generate_uuid).and_return('til-its-done')
    end

    context 'with a single expression' do
      it 'returns the correct metadata' do
        expect(component_conditional.to_metadata).to eq(expected_component_conditional)
      end
    end

    context 'with multiple expressions' do
      before do
        component_conditional_hash['expressions'].push(
          ComponentExpression.new('component' => '0987', 'page' => double(uuid: 'another-page-uuid'))
        )
      end

      it 'returns and as the condition type' do
        expect(component_conditional.to_metadata['_type']).to eq('and')
      end
    end
  end

  describe '#expressions' do
    let(:page) { service.find_page_by_url('do-you-like-star-wars') }
    let(:component) { page.components.first }
    let(:component_conditional_hash) do
      {
        'expressions' => [component_expression]
      }.merge(service:)
    end
    let(:component_expression) do
      ComponentExpression.new(
        {
          'operator' => 'is',
          'component' => component.uuid,
          'page' => page,
          'field' => 'some-field-id'
        }
      )
    end

    it 'returns an array of expressions' do
      expect(component_conditional.expressions).to eq([component_expression])
    end
  end

  describe '#component_expressions' do
    before do
      component_conditional.valid?
    end

    context 'when blank component expressions' do
      let(:component_conditional_hash) do
        {
          'expressions' => [
            ComponentExpression.new(
              {
                'operator' => '',
                'component' => '',
                'page' => 'some-page-uuid',
                'field' => ''
              }
            )
          ]
        }
      end

      it 'does not accept blank component expressions' do
        expect(component_conditional.expressions_validations).to be_present
      end

      it 'adds an error to the expression object' do
        errors = component_conditional.expressions.first.errors
        expect(errors).to be_present
        expect(errors.of_kind?(:component, :blank)).to be_truthy
      end
    end
  end
end
