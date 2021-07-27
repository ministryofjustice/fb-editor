RSpec.describe Expression do
  subject(:expression) do
    described_class.new(expression_hash)
  end
  let(:expression_hash) do
    {
      'operator': 'is',
      'page': 'some-page-uuid',
      'component': 'some-component-uuid',
      'field': 'some-field-uuid'
    }
  end
  let(:expected_expression) do
    {
      'operator' => 'is',
      'page' => 'some-page-uuid',
      'component' => 'some-component-uuid',
      'field' => 'some-field-uuid'
    }
  end

  describe '#to_metadata' do
    it 'returns the correct structure' do
      expect(expression.to_metadata).to eq(expected_expression)
    end
  end
end
