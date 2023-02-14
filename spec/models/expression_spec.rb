RSpec.describe Expression do
  subject(:expression) do
    described_class.new(expression_hash)
  end
  let(:expression_hash) { {} }

  describe '#to_metadata' do
    context 'when field has an answer' do
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

    context 'when field is nil' do
      let(:expression_hash) do
        {
          'operator': 'is_answered',
          'page': double(uuid: 'some-page-uuid'),
          'component': 'some-component-uuid',
          'field': nil
        }
      end
      let(:expected_expression) do
        {
          'operator' => 'is_answered',
          'page' => 'some-page-uuid',
          'component' => 'some-component-uuid',
          'field' => ''
        }
      end

      it 'returns the correct structure' do
        expect(expression.to_metadata).to eq(expected_expression)
      end
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

  describe '#all_operators' do
    let(:expected_operators) { Expression::OPERATORS }

    it 'returns all the operators' do
      expect(expression.all_operators).to eq(expected_operators)
    end
  end

  describe '#operators' do
    let(:metadata) { metadata_fixture(:branching) }
    let(:service) { MetadataPresenter::Service.new(metadata) }

    context 'when component type is checkboxes' do
      let(:page) { service.find_page_by_url('burgers') }
      let(:component) { page.components.find { |component| component.type == 'checkboxes' } }
      let(:expression_hash) do
        {
          'operator': 'contains',
          'page': page,
          'component': component.uuid,
          'field': 'some-field-uuid'
        }
      end
      let(:expected_operators) do
        [
          [I18n.t('operators.contains'), 'contains', { 'data-hide-answers': 'false' }],
          [I18n.t('operators.does_not_contain'), 'does_not_contain', { 'data-hide-answers': 'false' }],
          [I18n.t('operators.is_answered'), 'is_answered', { 'data-hide-answers': 'true' }],
          [I18n.t('operators.is_not_answered'), 'is_not_answered', { 'data-hide-answers': 'true' }]
        ]
      end

      it 'returns the expected operators' do
        expect(expression.operators).to eq(expected_operators)
      end
    end

    context 'when component type is radios' do
      let(:page) { service.find_page_by_url('star-wars-knowledge') }
      let(:component) { page.components.find { |component| component.type == 'radios' } }
      let(:expression_hash) do
        {
          'operator': 'contains',
          'page': page,
          'component': component.uuid,
          'field': 'some-field-uuid'
        }
      end
      let(:expected_operators) do
        [
          [I18n.t('operators.is'), 'is', { 'data-hide-answers': 'false' }],
          [I18n.t('operators.is_not'), 'is_not', { 'data-hide-answers': 'false' }],
          [I18n.t('operators.is_answered'), 'is_answered', { 'data-hide-answers': 'true' }],
          [I18n.t('operators.is_not_answered'), 'is_not_answered', { 'data-hide-answers': 'true' }]
        ]
      end

      it 'returns the expected operators' do
        expect(expression.operators).to eq(expected_operators)
      end
    end
  end

  describe '#component_type' do
    let(:page) { service.find_page_by_url('star-wars-knowledge') }
    let(:component) { page.components.find { |component| component.type == 'radios' } }
    let(:expression_hash) do
      {
        'operator': 'is',
        'page': page,
        'component': component.uuid,
        'field': 'some-field-uuid'
      }
    end

    it 'returns the the type of the component' do
      expect(expression.component_type).to eq('radios')
    end
  end

  describe '#name_attr' do
    let(:attributes) { %w[answer component operator field] }

    it 'constructs the correct name attribute' do
      attributes.each do |attribute|
        expect(
          expression.name_attr(
            conditional_index: 1,
            expression_index: 0,
            attribute:
          )
        ).to eq("branch[conditionals_attributes][1][expressions_attributes][0][#{attribute}]")
      end
    end
  end

  describe '#id_attr' do
    let(:attributes) { %w[component operator field] }

    it 'constructs the correct id attribute' do
      attributes.each do |attribute|
        expect(
          expression.id_attr(
            conditional_index: 0,
            expression_index: 1,
            attribute:
          )
        ).to eq("branch_conditionals_attributes_0_expressions_attributes_1_#{attribute}")
      end
    end
  end

  describe '#branching_support' do
    before do
      expression.valid?
    end

    context 'supported component' do
      let(:metadata) { metadata_fixture(:branching) }
      let(:service) { MetadataPresenter::Service.new(metadata) }
      let(:page) { service.find_page_by_url('do-you-like-star-wars') }

      let(:expression_hash) do
        {
          'operator': 'is',
          'page': page,
          'component': page.components.first.uuid,
          'field': 'c5571937-9388-4411-b5fa-34ddf9bc4ca0'
        }
      end

      it 'saves the metadata' do
        expect(expression.errors.messages).to be_empty
      end
    end

    context 'unsupported component' do
      let(:page) { service.find_page_by_url('name') }
      let(:expression_hash) do
        {
          'operator': 'is',
          'page': page,
          'component': page.components.first.uuid,
          'field': '27d377a2-6828-44ca-87d1-b83ddac98284'
        }
      end

      it 'returns the error message' do
        errors = expression.errors.messages
        expect(errors).to be_present
        expect(errors.values.first).to include(
          I18n.t(
            'activemodel.errors.messages.unsupported_component'
          )
        )
      end
    end

    context '#blank_field' do
      let(:page) { service.find_page_by_url('do-you-like-star-wars') }
      let(:expression_hash) do
        {
          'operator': 'is',
          'page': page,
          'component': page.components.first.uuid,
          'field': nil
        }
      end

      it 'returns the error message' do
        errors = expression.errors.messages
        expect(errors).to be_present
        expect(errors.values.first).to include(
          I18n.t(
            'activemodel.errors.messages.blank',
            attribute: Expression.human_attribute_name(:operator)
          )
        )
      end
    end
  end
end
