RSpec.describe Branch do
  subject(:branch) do
    described_class.new(branch_attributes)
  end
  let(:attributes) { {} }
  let(:branch_attributes) do
    {
      previous_flow_uuid: previous_flow_uuid,
      service: service
    }.merge(attributes)
  end
  let(:previous_flow_object) do
    service.find_page_by_url('holiday')
  end
  let(:previous_flow_uuid) do
    previous_flow_object.uuid
  end

  describe '.from_metadata' do
    let(:latest_metadata) { metadata_fixture(:branching) }
    let(:service) do
      MetadataPresenter::Service.new(latest_metadata)
    end
    let(:branch_uuid) { '09e91fd9-7a46-4840-adbc-244d545cfef7' }
    let(:branch_metadata) { service.flow_object(branch_uuid) }
    let(:expected_metadata) do
      {
        'conditionals_attributes' => {
          '0' => {
            'next' => 'e8708909-922e-4eaf-87a5-096f7a713fcb',
            'expressions_attributes' => {
              '0' => {
                'page' => '68fbb180-9a2a-48f6-9da6-545e28b8d35a',
                'component' => 'ac41be35-914e-4b22-8683-f5477716b7d4',
                'field' => 'c5571937-9388-4411-b5fa-34ddf9bc4ca0'
              }
            }
          }
        }
      }
    end

    it 'serialises the branch objects metadata' do
      expect(Branch.from_metadata(branch_metadata)).to eq(expected_metadata)
    end
  end

  describe '#conditionals_attributes=' do
    let(:attributes) do
      {
        'conditionals_attributes' => {
          '0' => {
            'next' => '3bbf86fc-701f-4cb6-8083-12404b293da0',
            'expressions_attributes' => {
              '0' => { 'component' => 'd1c04d9e-877f-4219-a96f-e21dde925f4b' }
            }
          }
        }
      }
    end
    let(:conditional) do
      object = Conditional.new(
        'next' => '3bbf86fc-701f-4cb6-8083-12404b293da0'
      )
      object.tap do
        object.expressions.push(
          Expression.new('component' => 'd1c04d9e-877f-4219-a96f-e21dde925f4b')
        )
      end
    end

    it 'assigns conditionals' do
      expect(branch.conditionals).to eq(
        [
          conditional
        ]
      )
    end
  end

  describe '#pages' do
    it 'returns all pages' do
      expect(branch.pages.map { |page| page[0] }).to eq(
        [
          'Service name goes here',
          'Full name',
          'Email address',
          'Parent name',
          'Your age',
          'Family Hobbies',
          'Do you like Star Wars?',
          'What is the day that you like to take holidays?',
          'What would you like on your burger?',
          'How well do you know Star Wars?',
          'Tell me how many lights you see',
          'Upload your best dog photo',
          'Check your answers',
          'Complaint sent'
        ]
      )
    end
  end

  describe '#previous_questions' do
    let(:previous_flow_object) do
      service.find_page_by_url('dog-picture')
    end

    it 'returns previous questions (only radios and checkboxes)' do
      expect(branch.previous_questions.map { |question| question[0] }).to eq(
        [
          'Do you like Star Wars?',
          'What would you like on your burger?',
          "What is The Mandalorian's real name?"
        ]
      )
    end
  end

  describe '#previous_flow_title' do
    it 'returns the title of the previous flow object' do
      expect(branch.previous_flow_title).to eq(previous_flow_object.title)
    end
  end

  describe '#previous_pages' do
    it 'returns all previously visited pages including the previous flow object' do
      expected_pages = service.pages[0..service.pages.index(previous_flow_object)]
      expect(branch.previous_pages).to eq(expected_pages)
    end
  end

  describe '#validations' do
    before do
      branch.valid?
    end

    context 'when blank conditionals' do
      let(:attributes) do
        {
          'conditionals_attributes' => {
            '0' => {
              'next' => '',
              'expressions_attributes' => {
                '0' => { 'component' => '' }
              }
            }
          }
        }
      end

      it 'does not accept blank conditionals' do
        expect(branch.errors[:conditionals]).to be_present
      end

      it 'adds error to conditionals object' do
        errors = branch.conditionals.first.errors
        expect(errors).to be_present
        expect(errors.of_kind?(:next, :blank)).to be_truthy
      end
    end

    context 'when valid conditionals' do
      let(:attributes) do
        {
          'conditionals_attributes' => {
            '0' => {
              'next' => SecureRandom.uuid,
              'expressions_attributes' => {
                '0' => { 'component' => SecureRandom.uuid }
              }
            }
          }
        }
      end

      it 'no errors on branch' do
        expect(branch.errors[:conditionals]).to be_blank
      end

      it 'no errors on conditionals' do
        errors = branch.conditionals.first.errors
        expect(errors).to be_blank
      end
    end
  end
end
