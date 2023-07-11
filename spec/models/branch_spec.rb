RSpec.describe Branch do
  subject(:branch) do
    described_class.new(branch_attributes)
  end
  let(:attributes) { {} }
  let(:branch_attributes) do
    {
      previous_flow_uuid:,
      service:
    }.merge(attributes)
  end
  let(:previous_page) do
    service.find_page_by_url('holiday')
  end
  let(:previous_flow_uuid) do
    previous_page.uuid
  end

  describe '#title' do
    subject(:branch) { described_class.new(service:) }
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
        expect(branch.title).to eq('Branching point 1')
      end
    end

    context 'when branches size met' do
      let(:branches) do
        [
          double(title: 'Branching point 1'),
          double(title: 'Branching point 2'),
          double(title: 'Branching point 3')
        ]
      end

      it 'returns next branching title' do
        expect(branch.title).to eq('Branching point 4')
      end
    end

    context 'when branches were deleted before' do
      let(:branches) do
        [
          double(title: 'Branching point 1'),
          double(title: 'Branching point 3'),
          double(title: 'Branching point 4')
        ]
      end

      it 'returns next branching title' do
        expect(branch.title).to eq('Branching point 5')
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
                'operator' => 'is',
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

  describe '#destinations' do
    let(:latest_metadata) { metadata_fixture(:branching) }
    let(:service) { MetadataPresenter::Service.new(latest_metadata) }
    let(:previous_page) do
      service.find_page_by_url('name')
    end
    let(:expected_destination_pages) do
      [
        'Full name',
        'Do you like Star Wars?',
        'How well do you know Star Wars?',
        'What is your favourite fruit?',
        'Do you like apple juice?',
        'Do you like orange juice?',
        'What is your favourite band?',
        'Which app do you use to listen music?',
        'What is the best form builder?',
        'Which Formbuilder is the best?',
        'What would you like on your burger?',
        'Global warming',
        'We love chickens',
        'What is the best marvel series?',
        'Loki',
        'Other quotes',
        'Select all Arnold Schwarzenegger quotes',
        'You are right',
        'You are wrong',
        'You are wrong',
        'Check your answers'
      ]
    end

    it 'returns valid destinations without branches' do
      expect(branch.destinations.map(&:first)).to eq(expected_destination_pages)
    end
  end

  describe '#previous_questions' do
    let(:previous_page) do
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
          'Upload your best dog photo',
          'Upload your best dog photos',
          'Countries'
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
          { 'data-supports-branching': false },
          { 'data-supports-branching': false },
          { 'data-supports-branching': false }
        ]
      )
    end
  end

  describe '#previous_flow_title' do
    it 'returns the title of the previous flow object' do
      expect(branch.previous_flow_title).to eq(previous_page.title)
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
        expect(branch.conditionals_validations).to be_present
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

  describe '#previous_flow_default_next' do
    let(:previous_flow_object) { service.flow_object(previous_flow_uuid) }

    it 'returns the default next uuid for the previous flow object' do
      expect(branch.previous_flow_default_next).to eq(previous_flow_object.default_next)
    end
  end

  describe '#previous_page_title' do
    let(:branch_attributes) do
      {
        branch_uuid:,
        service:
      }.merge(attributes)
    end
    let(:latest_metadata) { metadata_fixture(:branching) }
    let(:service) do
      MetadataPresenter::Service.new(latest_metadata)
    end
    let(:branch_uuid) { 'ffadeb22-063b-4e4f-9502-bd753c706b1d' } # Branching Point 2

    context 'when there are multiple uuids' do
      let(:metadata) { metadata_fixture(:branching) }
      let(:latest_metadata) do
        text_page = metadata['flow']['9e1ba77f-f1e5-42f4-b090-437aa9af7f73'] # Full name
        text_page['next']['default'] = branch_uuid

        star_wars_page = metadata['flow']['68fbb180-9a2a-48f6-9da6-545e28b8d35a']
        star_wars_page['next']['default'] = branch_uuid

        content_page = metadata['flow']['2cc66e51-2c14-4023-86bf-ded49887cdb2'] # Loki
        content_page['next']['default'] = branch_uuid

        metadata
      end

      it 'returns the title from the first uuid' do
        expect(branch.previous_page_title).to eq('Full name')
      end
    end

    context 'when the branch is unconnected' do
      let(:branch_attributes) do
        {
          branch_uuid:,
          service:
        }.merge(attributes)
      end
      let(:metadata) { metadata_fixture(:branching) }
      let(:checkanswers) do
        metadata['pages'].find { |p| p['_type'] == 'page.checkanswers' }
      end
      let(:latest_metadata) do
        obj = metadata['flow']['0b297048-aa4d-49b6-ac74-18e069118185'] # what is your favourite fruit
        obj['next']['default'] = checkanswers['_uuid']
        metadata
      end

      it 'returns nil' do
        expect(branch.previous_page_title).to be_nil
      end
    end
  end

  describe '#main_destinations' do
    let(:metadata) { metadata_fixture(:branching) }
    let(:service) { MetadataPresenter::Service.new(latest_metadata) }
    let(:checkanswers) do
      metadata['pages'].find { |p| p['_type'] == 'page.checkanswers' }
    end
    let(:latest_metadata) do
      obj = metadata['flow']['0b297048-aa4d-49b6-ac74-18e069118185'] # what is your favourite fruit
      obj['next']['default'] = checkanswers['_uuid']
      metadata
    end
    let(:previous_page) do
      service.find_page_by_url('name')
    end
    let(:expected_destination_pages) do
      ['Full name',
       'Do you like Star Wars?',
       'How well do you know Star Wars?',
       'What is your favourite fruit?',
       'Check your answers']
    end

    it 'returns destinations without detached pages' do
      expect(branch.main_destinations.map(&:first)).to eq(expected_destination_pages)
    end
  end

  describe '#detached_destinations' do
    let(:metadata) { metadata_fixture(:branching) }
    let(:service) { MetadataPresenter::Service.new(latest_metadata) }
    let(:checkanswers) do
      metadata['pages'].find { |p| p['_type'] == 'page.checkanswers' }
    end
    let(:latest_metadata) do
      obj = metadata['flow']['0b297048-aa4d-49b6-ac74-18e069118185'] # what is your favourite fruit
      obj['next']['default'] = checkanswers['_uuid']
      metadata
    end
    let(:previous_page) do
      service.find_page_by_url('name')
    end
    let(:detached_destination_pages) do
      [
        'Do you like orange juice?',
        'What is your favourite band?',
        'Which app do you use to listen music?',
        'What is the best form builder?',
        'Which Formbuilder is the best?',
        'What would you like on your burger?',
        'Global warming',
        'We love chickens',
        'What is the best marvel series?',
        'Loki',
        'Other quotes',
        'Select all Arnold Schwarzenegger quotes',
        'You are right',
        'You are wrong',
        'You are wrong',
        'Do you like apple juice?'
      ]
    end

    it 'returns destinations that are detached pages' do
      expect(branch.detached_destinations.map(&:first)).to eq(detached_destination_pages)
    end
  end
end
