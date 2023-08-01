RSpec.describe ConditionalContent do
  subject(:conditional_content) do
    described_class.new(conditional_content_attributes)
  end
  let(:attributes) { {} }
  let(:conditional_content_attributes) do
    {
      service:,
      previous_flow_uuid:,
      conditional_content_uuid:
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
  let(:conditional_content_uuid) { 'ac914bb1-c4b8-44a0-bacd-2d23a6597f1a' }
  let(:component_id) { '46a49bb2-349d-47f2-bb75-eaed3892d5d7' }
  let(:latest_metadata) { metadata_fixture(:conditional) }
  let(:service) do
    MetadataPresenter::Service.new(latest_metadata)
  end

  describe '.from_metadata' do
    let(:component) do
      current_page.find_component_by_uuid(component_id)
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
        }
      }
    end

    it 'serialises the branch objects metadata' do
      expect(ConditionalContent.from_metadata(component)).to eq(expected_metadata)
    end
  end

  describe '#previous_questions' do
    it 'returns all questions for single and mulitiple questions pages' do
      expect(conditional_content.previous_questions.map { |question| question[0] }).to eq(
        [
          'Checkbox',
          'Colours',
          'Pet choice'
        ]
      )
    end

    it 'injects the data-supports-branching attribute' do
      expect(conditional_content.previous_questions.map { |question| question[2] }).to eq(
        [
          { 'data-supports-branching': true },
          { 'data-supports-branching': true },
          { 'data-supports-branching': true }
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
              '0' => { 'component' => 'eb40d6c7-6c07-4c64-8891-f0b4d36ca123' }
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
            'component' => 'eb40d6c7-6c07-4c64-8891-f0b4d36ca123',
            'page' => double(uuid: 'some-page-uuid')
          )
        )
      end
    end

    it 'assigns conditionals' do
      expect(conditional_content.conditionals).to eq(
        [
          expected_conditional
        ]
      )
    end
  end
end
