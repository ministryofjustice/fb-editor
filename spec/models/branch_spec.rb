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

  describe '#title' do
    subject(:branch) { described_class.new(service: service) }
    let(:service) do
      MetadataPresenter::Service.new(metadata_fixture(:branching))
    end

    before do
      allow(service).to receive(:branches).and_return(branches)
    end

    context 'when branch has a title' do
      let(:branches) { [] }
      before do
        branch.title = 'Branch Variance Authority'
      end

      it 'returns title' do
        expect(branch.title).to eq('Branch Variance Authority')
      end
    end

    context 'when first branch' do
      let(:branches) { [] }

      it 'returns title' do
        expect(branch.title).to eq('Branching node 1')
      end
    end

    context 'when branches size met' do
      let(:branches) do
        [
          double(title: 'Branching node 1'),
          double(title: 'Branching node 2'),
          double(title: 'Branching node 3')
        ]
      end

      it 'returns next branching title' do
        expect(branch.title).to eq('Branching node 4')
      end
    end

    context 'when branches were deleted before' do
      let(:branches) do
        [
          double(title: 'Branching node 1'),
          double(title: 'Branching node 3'),
          double(title: 'Branching node 4')
        ]
      end

      it 'returns next branching title' do
        expect(branch.title).to eq('Branching node 5')
      end
    end
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
        'title' => branch_metadata['title'],
        'default_next' => '0b297048-aa4d-49b6-ac74-18e069118185',
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
    let(:expected_conditional) do
      object = Conditional.new(
        'next' => '3bbf86fc-701f-4cb6-8083-12404b293da0',
        'service' => service
      )
      object.tap do
        object.expressions.push(
          Expression.new(
            'component' => 'd1c04d9e-877f-4219-a96f-e21dde925f4b',
            'page' => double(uuid: 'some-page-uuid')
          )
        )
      end
    end

    it 'assigns conditionals' do
      expect(branch.conditionals).to eq(
        [
          expected_conditional
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

    it 'returns all questions for single and mulitiple questions pages' do
      expect(branch.previous_questions.map { |question| question[0] }).to eq(
        [
          'Full name',
          'Email address',
          'Parent name',
          'Your age',
          'Family Hobbies',
          'Do you like Star Wars?',
          'What is the day that you like to take holidays?',
          'What would you like on your burger?',
          "What was the name of the band playing in Jabba's palace?",
          "What is The Mandalorian's real name?",
          'Upload your best dog photo'
        ]
      )
    end

    it 'injects the data-supports-branching attribute' do
      expect(branch.previous_questions.map { |question| question[2] }).to eq(
        [
          { 'data-supports-branching': false },
          { 'data-supports-branching': false },
          { 'data-supports-branching': false },
          { 'data-supports-branching': false },
          { 'data-supports-branching': false },
          { 'data-supports-branching': true },
          { 'data-supports-branching': false },
          { 'data-supports-branching': true },
          { 'data-supports-branching': false },
          { 'data-supports-branching': true },
          { 'data-supports-branching': false }
        ]
      )
    end
  end

  describe '#previous_flow_title' do
    it 'returns the title of the previous flow object' do
      expect(branch.previous_flow_title).to eq(previous_flow_object.title)
    end
  end

  describe '#validations' do
    before do
      branch.valid?
    end

    context 'when there is no default next' do
      let(:attributes) do
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

      it 'does not accept blank default next' do
        expect(branch.errors[:default_next]).to be_present
      end

      it 'adds an error to the branch object' do
        errors = branch.errors
        expect(errors).to be_present
        expect(errors.of_kind?(:default_next, :blank)).to be_truthy
      end
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
                '0' => {
                  'operator' => 'is',
                  'component' => SecureRandom.uuid,
                  'page' => double(uuid: 'some-page-uuid'),
                  'field' => 'some-field-uuid'
                }
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
