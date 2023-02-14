RSpec.describe Conditional do
  subject(:conditional) do
    described_class.new(conditional_hash)
  end
  let(:conditional_hash) do
    {
      'next' => '12345',
      'expressions' => [
        Expression.new(
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
  let(:expected_conditional) do
    {
      '_uuid' => 'you-can-do-it',
      '_type' => 'if',
      'next' => '12345',
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
      allow(conditional).to receive(:generate_uuid).and_return('you-can-do-it')
    end

    context 'with a single expression' do
      it 'returns the correct metadata' do
        expect(conditional.to_metadata).to eq(expected_conditional)
      end
    end

    context 'with multiple expressions' do
      before do
        conditional_hash['expressions'].push(
          Expression.new('component' => '0987', 'page' => double(uuid: 'some-page-uuid'))
        )
      end

      it 'returns and as the condition type' do
        expect(conditional.to_metadata['_type']).to eq('and')
      end
    end
  end

  describe '#expressions' do
    let(:page) { service.find_page_by_url('do-you-like-star-wars') }
    let(:component) { page.components.first }
    let(:conditional_hash) do
      {
        'next' => '12345',
        'expressions' => [expression]
      }.merge(service:)
    end
    let(:expression) do
      Expression.new(
        {
          'operator' => 'is',
          'component' => component.uuid,
          'page' => page,
          'field' => 'some-field-id'
        }
      )
    end

    it 'returns an array of expressions' do
      expect(conditional.expressions).to eq([expression])
    end
  end

  describe '#component_expressions' do
    before do
      conditional.valid?
    end

    context 'when blank component expressions' do
      let(:conditional_hash) do
        {
          'next' => '12345',
          'expressions' => [
            Expression.new(
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
        expect(conditional.expressions_validations).to be_present
      end

      it 'adds an error to the expression object' do
        errors = conditional.expressions.first.errors
        expect(errors).to be_present
        expect(errors.of_kind?(:component, :blank)).to be_truthy
      end
    end
  end
end
