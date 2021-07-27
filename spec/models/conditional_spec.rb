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
            'page' => 'some=page-uuid',
            'field' => 'some-field-uuid'
          }
        )
      ]
    }
  end
  let(:expected_conditional) do
    {
      '_type' => 'if',
      'next' => '12345',
      'expressions' => [
        {
          'operator' => 'is',
          'component' => '67890',
          'page' => 'some=page-uuid',
          'field' => 'some-field-uuid'
        }
      ]
    }
  end

  describe '#to_metadata' do
    context 'with a single expression' do
      it 'returns the correct metadata' do
        expect(conditional.to_metadata).to eq(expected_conditional)
      end
    end

    context 'with multiple expressions' do
      before do
        conditional_hash['expressions'].push(
          Expression.new('component' => '0987')
        )
      end

      it 'returns and as the condition type' do
        expect(conditional.to_metadata['_type']).to eq('and')
      end
    end
  end
end
