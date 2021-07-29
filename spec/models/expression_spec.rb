RSpec.describe Expression do
  subject(:expression) do
    described_class.new(expression_hash)
  end

  describe '#to_metadata' do
    let(:expression_hash) do
      {
        'operator': 'is',
        'page': double(uuid: 'some-page-uuid'),
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

    it 'returns the correct structure' do
      expect(expression.to_metadata).to eq(expected_expression)
    end
  end

  describe '#answers' do
    let(:metadata) { metadata_fixture(:branching) }
    let(:service) { MetadataPresenter::Service.new(metadata) }
    let(:page) { service.find_page_by_url('do-you-like-star-wars') }

    let(:expression_hash) do
      {
        'operator': 'is',
        'page': page,
        'component': page.components.first.uuid,
        'field': ''
      }
    end
    let(:answers) do
      [
        ['Only on weekends', 'c5571937-9388-4411-b5fa-34ddf9bc4ca0'],
        ['Hell no!', '67160ff1-6f7c-43a8-8bf6-49b3d5f450f6']
      ]
    end

    it 'returns a list of answers' do
      expect(expression.answers).to eq(answers)
    end
  end

  describe '#operators' do
    let(:expression_hash) { {} }
    let(:expected_operators) { Expression::OPERATORS }

    it 'returns all the operators' do
      expect(expression.operators).to eq(expected_operators)
    end
  end
end
