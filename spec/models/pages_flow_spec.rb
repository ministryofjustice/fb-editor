RSpec.describe PagesFlow do
  subject(:pages_flow) { described_class.new(service) }
  let(:metadata) { metadata_fixture(:branching) }
  let(:service) { MetadataPresenter::Service.new(metadata) }

  describe '#build' do
    before do
      # shuffle the service flow as we do not enforce its order
      allow(service).to receive(:flow_objects).and_return(
        service.flow_objects.shuffle
      )
    end

    context 'service with no branching' do
      let(:metadata) { metadata_fixture(:version) }
      let(:expected_flow_uuids) { metadata['flow'].keys }

      it 'builds the service flow in the correct order and structure' do
        ordered_flow_uuids = pages_flow.build.map { |flow| flow[:uuid] }
        expect(ordered_flow_uuids).to eq(expected_flow_uuids)
      end
    end

    context 'service with branching' do
      let(:expected_flow) do
        [
          {
            type: 'page.start',
            title: 'Service name goes here',
            uuid: 'cf6dc32f-502c-4215-8c27-1151a45735bb',
            next: '9e1ba77f-f1e5-42f4-b090-437aa9af7f73'
          },
          {
            type: 'page.singlequestion',
            title: 'Full name',
            uuid: '9e1ba77f-f1e5-42f4-b090-437aa9af7f73',
            next: '68fbb180-9a2a-48f6-9da6-545e28b8d35a'
          },
          {
            type: 'page.singlequestion',
            title: 'Do you like Star Wars?',
            uuid: '68fbb180-9a2a-48f6-9da6-545e28b8d35a',
            next: '09e91fd9-7a46-4840-adbc-244d545cfef7'
          },
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
          },
          {
            type: 'page.multiplequestions',
            title: 'How well do you know Star Wars?',
            uuid: 'e8708909-922e-4eaf-87a5-096f7a713fcb',
            next: '0b297048-aa4d-49b6-ac74-18e069118185'
          },
          {
            title: 'What is your favourite fruit?',
            type: 'page.singlequestion',
            uuid: '0b297048-aa4d-49b6-ac74-18e069118185',
            next: 'ffadeb22-063b-4e4f-9502-bd753c706b1d'
          },
          {
            type: 'flow.branch',
            title: 'Branching point 2',
            uuid: 'ffadeb22-063b-4e4f-9502-bd753c706b1d',
            conditionals: [
              {
                next: 'd4342dfd-0d09-4a91-a0ea-d7fd67e706cc',
                expressions: [
                  {
                    question: 'What is your favourite fruit?',
                    answer: 'is Apples'
                  }
                ]
              },
              {
                next: '91e9f7c6-2f75-4b7d-9eb5-0cf352f7be66',
                expressions: [
                  {
                    question: 'What is your favourite fruit?',
                    answer: 'is Oranges'
                  }
                ]
              },
              {
                next: '05c3306c-0a39-42d2-9e0f-93fd49248f4e',
                expressions: [
                  {
                    question: 'Otherwise',
                    answer: ''
                  }
                ]
              }
            ]
          },
          {
            type: 'page.singlequestion',
            title: 'Do you like apple juice?',
            uuid: 'd4342dfd-0d09-4a91-a0ea-d7fd67e706cc',
            next: '05c3306c-0a39-42d2-9e0f-93fd49248f4e'
          },
          {
            type: 'page.singlequestion',
            title: 'Do you like orange juice?',
            uuid: '91e9f7c6-2f75-4b7d-9eb5-0cf352f7be66',
            next: '05c3306c-0a39-42d2-9e0f-93fd49248f4e'
          },
          {
            type: 'page.singlequestion',
            title: 'What is your favourite band?',
            uuid: '05c3306c-0a39-42d2-9e0f-93fd49248f4e',
            next: '1d02e508-5953-4eca-af2f-9d67511c8648'
          },
          {
            type: 'flow.branch',
            title: 'Branching point 3',
            uuid: '1d02e508-5953-4eca-af2f-9d67511c8648',
            conditionals: [
              {
                next: '8002df6e-29ab-4cdf-b520-1d7bb931a28f',
                expressions: [
                  {
                    question: 'What is your favourite band?',
                    answer: 'is answered'
                  }
                ]
              },
              {
                next: 'ef2cafe3-37e2-4533-9b0c-09a970cd38d4',
                expressions: [
                  {
                    question: 'Otherwise',
                    answer: ''
                  }
                ]
              }
            ]
          },
          {
            type: 'page.singlequestion',
            title: 'Which app do you use to listen music?',
            uuid: '8002df6e-29ab-4cdf-b520-1d7bb931a28f',
            next: 'ef2cafe3-37e2-4533-9b0c-09a970cd38d4'
          },
          {
            type: 'page.singlequestion',
            title: 'What is the best form builder?',
            uuid: 'ef2cafe3-37e2-4533-9b0c-09a970cd38d4',
            next: 'cf8b3e18-dacf-4e91-92e1-018035961003'
          },
          {
            type: 'flow.branch',
            title: 'Branching point 4',
            uuid: 'cf8b3e18-dacf-4e91-92e1-018035961003',
            conditionals: [
              {
                next: 'b5efc09c-ece7-45ae-b0b3-8a7905e25040',
                expressions: [
                  {
                    question: 'What is the best form builder?',
                    answer: 'is not MoJ'
                  }
                ]
              },
              {
                next: '0c022e95-0748-4dda-8ba5-12fd1d2f596b',
                expressions: [
                  {
                    question: 'Otherwise',
                    answer: ''
                  }
                ]
              }
            ]
          },
          {
            type: 'page.singlequestion',
            title: 'Which Formbuilder is the best?',
            uuid: 'b5efc09c-ece7-45ae-b0b3-8a7905e25040',
            next: '0c022e95-0748-4dda-8ba5-12fd1d2f596b'
          },
          {
            type: 'page.singlequestion',
            title: 'What would you like on your burger?',
            uuid: '0c022e95-0748-4dda-8ba5-12fd1d2f596b',
            next: '618b7537-b42b-4551-ae7d-053afa4d9ca9'
          },
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
          },
          {
            type: 'page.content',
            title: 'Global warming',
            uuid: 'bc666714-c0a2-4674-afe5-faff2e20d847',
            next: 'dc7454f9-4186-48d7-b055-684d57bbcdc7'
          },
          {
            type: 'page.content',
            title: 'We love chickens',
            uuid: 'e2887f44-5e8d-4dc0-b1de-496ab6039430',
            next: 'dc7454f9-4186-48d7-b055-684d57bbcdc7'
          },
          {
            type: 'page.singlequestion',
            title: 'What is the best marvel series?',
            uuid: 'dc7454f9-4186-48d7-b055-684d57bbcdc7',
            next: '84a347fc-8d4b-486a-9996-6a86fa9544c5'
          },
          {
            type: 'flow.branch',
            title: 'Branching point 6',
            uuid: '84a347fc-8d4b-486a-9996-6a86fa9544c5',
            conditionals: [
              {
                next: '2cc66e51-2c14-4023-86bf-ded49887cdb2',
                expressions: [
                  {
                    question: 'What is the best marvel series?',
                    answer: 'is The Falcon and the Winter Soldier'
                  }
                ]
              },
              {
                next: '2cc66e51-2c14-4023-86bf-ded49887cdb2',
                expressions: [
                  {
                    question: 'What is the best marvel series?',
                    answer: 'is Loki'
                  }
                ]
              },
              {
                next: 'f6c51f88-7be8-4cb7-bbfc-6c905727a051',
                expressions: [
                  {
                    question: 'Do you like Star Wars?',
                    answer: 'is Only on weekends'
                  },
                  {
                    question: 'What is the best marvel series?',
                    answer: 'is WandaVision'
                  }
                ]
              },
              {
                next: '48357db5-7c06-4e85-94b1-5e1c9d8f39eb',
                expressions: [
                  {
                    question: 'Otherwise',
                    answer: ''
                  }
                ]
              }
            ]
          },
          {
            type: 'page.content',
            title: 'Loki',
            uuid: '2cc66e51-2c14-4023-86bf-ded49887cdb2',
            next: '48357db5-7c06-4e85-94b1-5e1c9d8f39eb'
          },
          {
            type: 'page.content',
            title: 'Other quotes',
            uuid: 'f6c51f88-7be8-4cb7-bbfc-6c905727a051',
            next: '48357db5-7c06-4e85-94b1-5e1c9d8f39eb'
          },
          {
            type: 'page.singlequestion',
            title: 'Select all Arnold Schwarzenegger quotes',
            uuid: '48357db5-7c06-4e85-94b1-5e1c9d8f39eb',
            next: '1079b5b8-abd0-4bf6-aaac-1f01e69e3b39'
          },
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
          },
          {
            type: 'page.content',
            title: 'You are right',
            uuid: '56e80942-d0a4-405a-85cd-bd1b100013d6',
            next: 'e337070b-f636-49a3-a65c-f506675265f0'
          },
          {
            type: 'page.content',
            title: 'You are wrong', # wrong answers, GOTG quotes
            uuid: '6324cca4-7770-4765-89b9-1cdc41f49c8b',
            next: 'e337070b-f636-49a3-a65c-f506675265f0'
          },
          {
            type: 'page.content',
            title: 'You are wrong', # incomplete answers, Otherwise
            uuid: '941137d7-a1da-43fd-994a-98a4f9ea6d46',
            next: 'e337070b-f636-49a3-a65c-f506675265f0'
          },
          {
            type: 'page.checkanswers',
            title: 'Check your answers',
            uuid: 'e337070b-f636-49a3-a65c-f506675265f0',
            next: '778e364b-9a7f-4829-8eb2-510e08f156a3'
          },
          {
            type: 'page.confirmation',
            title: 'Complaint sent',
            uuid: '778e364b-9a7f-4829-8eb2-510e08f156a3',
            next: ''
          }
        ]
      end

      it 'builds the service flow in the correct order and structure' do
        expect(pages_flow.build).to eq(expected_flow)
      end
    end
  end

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

    context 'conditional type not implemented' do
      let(:invalid_type) { 'until' }
      let(:branch_metadata) do
        {
          '1079b5b8-abd0-4bf6-aaac-1f01e69e3b39' => {
            '_type' => 'flow.branch',
            'title' => 'Branching point 1 billion',
            'next' => {
              'default' => '941137d7-a1da-43fd-994a-98a4f9ea6d46',
              'conditionals' => [
                {
                  '_type' => invalid_type,
                  'next' => '56e80942-d0a4-405a-85cd-bd1b100013d6',
                  'expressions' => []
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
      it 'should raise NotImplementedError' do
        expect { pages_flow.branch(flow) }.to raise_error(
          NotImplementedError, "'#{invalid_type}' method not implemented"
        )
      end
    end
  end
end
