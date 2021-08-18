RSpec.describe PagesFlow do
  subject(:pages_flow) { described_class.new(service) }
  let(:metadata) { metadata_fixture(:branching) }
  let(:service) { MetadataPresenter::Service.new(metadata) }

  describe '#page' do
    let(:flow) { service.flow_object('ef2cafe3-37e2-4533-9b0c-09a970cd38d4') }
    let(:expected_page) do
      {
        type: 'page.singlequestion',
        title: 'What is the best form builder?',
        uuid: 'ef2cafe3-37e2-4533-9b0c-09a970cd38d4',
        next: 'cf8b3e18-dacf-4e91-92e1-018035961003'
      }
    end

    it 'should create the expected page structure' do
      expect(pages_flow.page(flow)).to eq(expected_page)
    end
  end

  describe '#branch' do
    context 'conditionals with single expression' do
      let(:flow) { service.flow_object('09e91fd9-7a46-4840-adbc-244d545cfef7') }
      let(:expected_branch) do
        {
          type: 'flow.branch',
          title: 'Branching point 1',
          uuid: '09e91fd9-7a46-4840-adbc-244d545cfef7',
          conditionals: [
            {
              next: 'e8708909-922e-4eaf-87a5-096f7a713fcb',
              expressions: [
                {
                  question: 'Do you like Star Wars?',
                  answer: 'is Only on weekends'
                }
              ]
            },
            {
              next: '0b297048-aa4d-49b6-ac74-18e069118185',
              expressions: [
                {
                  question: 'Otherwise',
                  answer: ''
                }
              ]
            }
          ]
        }
      end

      it 'should create the expected branch structure' do
        expect(pages_flow.branch(flow)).to eq(expected_branch)
      end
    end

    context 'branch with OR conditionals' do
      let(:flow) { service.flow_object('618b7537-b42b-4551-ae7d-053afa4d9ca9') }
      let(:expected_branch) do
        {
          type: 'flow.branch',
          title: 'Branching point 5',
          uuid: '618b7537-b42b-4551-ae7d-053afa4d9ca9',
          conditionals: [
            {
              next: 'bc666714-c0a2-4674-afe5-faff2e20d847',
              expressions: [
                {
                  question: 'What would you like on your burger?',
                  answer: 'is Beef, cheese, tomato'
                }
              ]
            },
            {
              next: 'e2887f44-5e8d-4dc0-b1de-496ab6039430',
              expressions: [
                {
                  question: 'What would you like on your burger?',
                  answer: 'is not Beef, cheese, tomato'
                }
              ]
            },
            {
              next: 'dc7454f9-4186-48d7-b055-684d57bbcdc7',
              expressions: [
                {
                  question: 'Otherwise',
                  answer: ''
                }
              ]
            }
          ]
        }
      end

      it 'should create the expected branch structure' do
        expect(pages_flow.branch(flow)).to eq(expected_branch)
      end
    end

    context 'conditional with AND expressions' do
      let(:branch_metadata) do
        {
          '1079b5b8-abd0-4bf6-aaac-1f01e69e3b39' => {
            '_type' => 'flow.branch',
            'title' => 'Branching point 7',
            'next' => {
              'default' => '941137d7-a1da-43fd-994a-98a4f9ea6d46',
              'conditionals' => [
                {
                  '_type' => 'and',
                  'next' => '56e80942-d0a4-405a-85cd-bd1b100013d6',
                  'expressions' => [
                    {
                      'operator' => 'is',
                      'page' => '48357db5-7c06-4e85-94b1-5e1c9d8f39eb',
                      'component' => '3a430712-a75f-4412-836d-4ec7b2cb1ac9',
                      'field' => '30258b55-ec04-4278-86b7-8382cbd34bea'
                    },
                    {
                      'operator' => 'is',
                      'page' => '48357db5-7c06-4e85-94b1-5e1c9d8f39eb',
                      'component' => '3a430712-a75f-4412-836d-4ec7b2cb1ac9',
                      'field' => '9339d86e-b53c-42c0-ab6e-1ab3e2340873'
                    },
                    {
                      'operator' => 'is',
                      'page' => '48357db5-7c06-4e85-94b1-5e1c9d8f39eb',
                      'component' => '3a430712-a75f-4412-836d-4ec7b2cb1ac9',
                      'field' => '5d650e5d-57ac-42a1-9348-c1b93248753a'
                    }
                  ]
                }
              ]
            }
          }
        }
      end
      let(:flow) do
        MetadataPresenter::Flow.new(
          '1079b5b8-abd0-4bf6-aaac-1f01e69e3b39',
          branch_metadata['1079b5b8-abd0-4bf6-aaac-1f01e69e3b39']
        )
      end
      let(:expected_branch) do
        {
          type: 'flow.branch',
          title: 'Branching point 7',
          uuid: '1079b5b8-abd0-4bf6-aaac-1f01e69e3b39',
          conditionals: [
            {
              next: '56e80942-d0a4-405a-85cd-bd1b100013d6',
              expressions: [
                {
                  question: 'Select all Arnold Schwarzenegger quotes',
                  answer: 'is You are not you. You are me'
                },
                {
                  question: 'Select all Arnold Schwarzenegger quotes',
                  answer: 'is Get to the chopper'
                },
                {
                  question: 'Select all Arnold Schwarzenegger quotes',
                  answer: 'is You have been terminated'
                }
              ]
            },
            {
              next: '941137d7-a1da-43fd-994a-98a4f9ea6d46',
              expressions: [
                {
                  question: 'Otherwise',
                  answer: ''
                }
              ]
            }
          ]
        }
      end

      it 'should create the expected branch structure' do
        expect(pages_flow.branch(flow)).to eq(expected_branch)
      end
    end

    # Expressions with OR are supported by the runner, but not currently
    # supported to be created via the editor interface.
    # Test for them anyway
    # OR expressions get broken out into separate conditional objects
    # despite them going to the same destination as that is how the frontend
    # will iterate over them to build the flow
    context 'conditionals with AND and OR expressions' do
      let(:flow) { service.flow_object('1079b5b8-abd0-4bf6-aaac-1f01e69e3b39') }
      let(:expected_branch) do
        {
          type: 'flow.branch',
          title: 'Branching point 7',
          uuid: '1079b5b8-abd0-4bf6-aaac-1f01e69e3b39',
          conditionals: [
            {
              next: '56e80942-d0a4-405a-85cd-bd1b100013d6',
              expressions: [
                {
                  question: 'Select all Arnold Schwarzenegger quotes',
                  answer: 'is You are not you. You are me'
                },
                {
                  question: 'Select all Arnold Schwarzenegger quotes',
                  answer: 'is Get to the chopper'
                },
                {
                  question: 'Select all Arnold Schwarzenegger quotes',
                  answer: 'is You have been terminated'
                }
              ]
            },
            {
              next: '6324cca4-7770-4765-89b9-1cdc41f49c8b',
              expressions: [
                {
                  question: 'Select all Arnold Schwarzenegger quotes',
                  answer: 'is I am GROOT'
                }
              ]
            },
            {
              next: '6324cca4-7770-4765-89b9-1cdc41f49c8b',
              expressions: [
                {
                  question: 'Select all Arnold Schwarzenegger quotes',
                  answer: 'is Dance Off, Bro.'
                }
              ]
            },
            {
              next: '941137d7-a1da-43fd-994a-98a4f9ea6d46',
              expressions: [
                {
                  question: 'Otherwise',
                  answer: ''
                }
              ]
            }
          ]
        }
      end

      it 'should create the expected branch structure' do
        expect(pages_flow.branch(flow)).to eq(expected_branch)
      end
    end
  end
end
