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
      let(:expected_flow) do
        [
          [
            {
              type: 'page.start',
              title: 'Service name goes here',
              uuid: 'cf6dc32f-502c-4215-8c27-1151a45735bb',
              next: '9e1ba77f-f1e5-42f4-b090-437aa9af7f73',
              thumbnail: 'start',
              url: '/'
            }
          ],
          [
            {
              type: 'page.singlequestion',
              title: 'Full name',
              uuid: '9e1ba77f-f1e5-42f4-b090-437aa9af7f73',
              next: 'df1ba645-f748-46d0-ad75-f34112653e37',
              thumbnail: 'text',
              url: 'name'
            }
          ],
          [
            {
              type: 'page.singlequestion',
              title: 'Email address',
              uuid: 'df1ba645-f748-46d0-ad75-f34112653e37',
              next: '4b8c6bf3-878a-4446-9198-48351b3e2185',
              thumbnail: 'text',
              url: 'email-address'
            }
          ],
          [
            {
              type: 'page.singlequestion',
              title: 'Parent name',
              uuid: '4b8c6bf3-878a-4446-9198-48351b3e2185',
              next: '54ccc6cd-60c0-4749-947b-a97af1bc0aa2',
              thumbnail: 'text',
              url: 'parent-name'
            }
          ],
          [
            {
              type: 'page.singlequestion',
              title: 'Your age',
              uuid: '54ccc6cd-60c0-4749-947b-a97af1bc0aa2',
              next: 'b8335af2-6642-4e2f-8192-0dd12279eec7',
              thumbnail: 'number',
              url: 'your-age'
            }
          ],
          [
            {
              type: 'page.singlequestion',
              title: 'Family Hobbies',
              uuid: 'b8335af2-6642-4e2f-8192-0dd12279eec7',
              next: '68fbb180-9a2a-48f6-9da6-545e28b8d35a',
              thumbnail: 'textarea',
              url: 'family-hobbies'
            }
          ],
          [
            {
              type: 'page.singlequestion',
              title: 'Do you like Star Wars?',
              uuid: '68fbb180-9a2a-48f6-9da6-545e28b8d35a',
              next: '7806cd64-0c05-450e-ba6f-2325c8b22d46',
              thumbnail: 'radios',
              url: 'do-you-like-star-wars'
            }
          ],
          [
            {
              type: 'page.singlequestion',
              title: 'What is the day that you like to take holidays?',
              uuid: '7806cd64-0c05-450e-ba6f-2325c8b22d46',
              next: '0c022e95-0748-4dda-8ba5-12fd1d2f596b',
              thumbnail: 'date',
              url: 'holiday'
            }
          ],
          [
            {
              type: 'page.singlequestion',
              title: 'What would you like on your burger?',
              uuid: '0c022e95-0748-4dda-8ba5-12fd1d2f596b',
              next: 'e8708909-922e-4eaf-87a5-096f7a713fcb',
              thumbnail: 'checkboxes',
              url: 'burgers'
            }
          ],
          [
            {
              type: 'page.multiplequestions',
              title: 'How well do you know Star Wars?',
              uuid: 'e8708909-922e-4eaf-87a5-096f7a713fcb',
              next: '80420693-d6f2-4fce-a860-777ca774a6f5',
              thumbnail: 'text',
              url: 'star-wars-knowledge'
            }
          ],
          [
            {
              type: 'page.content',
              title: 'Tell me how many lights you see',
              uuid: '80420693-d6f2-4fce-a860-777ca774a6f5',
              next: '2ef7d11e-0307-49e9-9fe2-345dc528dd66',
              thumbnail: 'content',
              url: 'how-many-lights'
            }
          ],
          [
            {
              type: 'page.singlequestion',
              title: 'Upload your best dog photo',
              uuid: '2ef7d11e-0307-49e9-9fe2-345dc528dd66',
              next: 'e337070b-f636-49a3-a65c-f506675265f0',
              thumbnail: 'upload',
              url: 'dog-picture'
            }
          ],
          [
            {
              type: 'page.checkanswers',
              title: 'Check your answers',
              uuid: 'e337070b-f636-49a3-a65c-f506675265f0',
              next: '778e364b-9a7f-4829-8eb2-510e08f156a3',
              thumbnail: 'checkanswers',
              url: 'check-answers'
            }
          ],
          [
            {
              type: 'page.confirmation',
              title: 'Complaint sent',
              uuid: '778e364b-9a7f-4829-8eb2-510e08f156a3',
              next: '',
              thumbnail: 'confirmation',
              url: 'confirmation'
            }
          ]
        ]
      end

      it 'builds the service flow in the correct order and structure' do
        expect(pages_flow.build).to eq(expected_flow)
      end

      it 'does not duplicate any flow objects' do
        flow_uuids = pages_flow.build.flatten.map { |flow| flow[:uuid] }
        expect(flow_uuids.uniq.size).to eq(service.flow.size)
      end
    end

    context 'service with branching' do
      let(:expected_flow) do
        [
          [
            {
              type: 'page.start',
              title: 'Service name goes here',
              uuid: 'cf6dc32f-502c-4215-8c27-1151a45735bb',
              next: '9e1ba77f-f1e5-42f4-b090-437aa9af7f73',
              thumbnail: 'start',
              url: '/'
            }
          ],
          [
            {
              type: 'page.singlequestion',
              title: 'Full name',
              uuid: '9e1ba77f-f1e5-42f4-b090-437aa9af7f73',
              next: '68fbb180-9a2a-48f6-9da6-545e28b8d35a',
              thumbnail: 'text',
              url: 'name'
            }
          ],
          [
            {
              type: 'page.singlequestion',
              title: 'Do you like Star Wars?',
              uuid: '68fbb180-9a2a-48f6-9da6-545e28b8d35a',
              next: '09e91fd9-7a46-4840-adbc-244d545cfef7',
              thumbnail: 'radios',
              url: 'do-you-like-star-wars'
            }
          ],
          [
            {
              type: 'flow.branch',
              title: 'Branching point 1',
              uuid: '09e91fd9-7a46-4840-adbc-244d545cfef7',
              thumbnail: 'branch',
              conditionals: [
                {
                  next: 'e8708909-922e-4eaf-87a5-096f7a713fcb',
                  expressions: [
                    {
                      question: 'Do you like Star Wars?',
                      operator: 'is',
                      answer: 'Only on weekends'
                    }
                  ]
                },
                {
                  next: '0b297048-aa4d-49b6-ac74-18e069118185',
                  expressions: [
                    {
                      question: 'Otherwise',
                      operator: '',
                      answer: ''
                    }
                  ]
                }
              ]
            }
          ],
          [
            {
              type: 'page.multiplequestions',
              title: 'How well do you know Star Wars?',
              uuid: 'e8708909-922e-4eaf-87a5-096f7a713fcb',
              next: '0b297048-aa4d-49b6-ac74-18e069118185',
              thumbnail: 'text',
              url: 'star-wars-knowledge'
            }
          ],
          [
            {
              title: 'What is your favourite fruit?',
              type: 'page.singlequestion',
              uuid: '0b297048-aa4d-49b6-ac74-18e069118185',
              next: 'ffadeb22-063b-4e4f-9502-bd753c706b1d',
              thumbnail: 'radios',
              url: 'favourite-fruit'
            }
          ],
          [
            {
              type: 'flow.branch',
              title: 'Branching point 2',
              uuid: 'ffadeb22-063b-4e4f-9502-bd753c706b1d',
              thumbnail: 'branch',
              conditionals: [
                {
                  next: 'd4342dfd-0d09-4a91-a0ea-d7fd67e706cc',
                  expressions: [
                    {
                      question: 'What is your favourite fruit?',
                      operator: 'is',
                      answer: 'Apples'
                    }
                  ]
                },
                {
                  next: '91e9f7c6-2f75-4b7d-9eb5-0cf352f7be66',
                  expressions: [
                    {
                      question: 'What is your favourite fruit?',
                      operator: 'is',
                      answer: 'Oranges'
                    }
                  ]
                },
                {
                  next: '05c3306c-0a39-42d2-9e0f-93fd49248f4e',
                  expressions: [
                    {
                      question: 'Otherwise',
                      operator: '',
                      answer: ''
                    }
                  ]
                }
              ]
            }
          ],
          [
            {
              type: 'page.singlequestion',
              title: 'Do you like apple juice?',
              uuid: 'd4342dfd-0d09-4a91-a0ea-d7fd67e706cc',
              next: '05c3306c-0a39-42d2-9e0f-93fd49248f4e',
              thumbnail: 'radios',
              url: 'apple-juice'
            },
            {
              type: 'page.singlequestion',
              title: 'Do you like orange juice?',
              uuid: '91e9f7c6-2f75-4b7d-9eb5-0cf352f7be66',
              next: '05c3306c-0a39-42d2-9e0f-93fd49248f4e',
              thumbnail: 'radios',
              url: 'orange-juice'
            }
          ],
          [
            {
              type: 'page.singlequestion',
              title: 'What is your favourite band?',
              uuid: '05c3306c-0a39-42d2-9e0f-93fd49248f4e',
              next: '1d02e508-5953-4eca-af2f-9d67511c8648',
              thumbnail: 'radios',
              url: 'favourite-band'
            }
          ],
          [
            {
              type: 'flow.branch',
              title: 'Branching point 3',
              uuid: '1d02e508-5953-4eca-af2f-9d67511c8648',
              thumbnail: 'branch',
              conditionals: [
                {
                  next: '8002df6e-29ab-4cdf-b520-1d7bb931a28f',
                  expressions: [
                    {
                      question: 'What is your favourite band?',
                      operator: 'is answered',
                      answer: ''
                    }
                  ]
                },
                {
                  next: 'ef2cafe3-37e2-4533-9b0c-09a970cd38d4',
                  expressions: [
                    {
                      question: 'Otherwise',
                      operator: '',
                      answer: ''
                    }
                  ]
                }
              ]
            }
          ],
          [
            {
              type: 'page.singlequestion',
              title: 'Which app do you use to listen music?',
              uuid: '8002df6e-29ab-4cdf-b520-1d7bb931a28f',
              next: 'ef2cafe3-37e2-4533-9b0c-09a970cd38d4',
              thumbnail: 'radios',
              url: 'music-app'
            }
          ],
          [
            {
              type: 'page.singlequestion',
              title: 'What is the best form builder?',
              uuid: 'ef2cafe3-37e2-4533-9b0c-09a970cd38d4',
              next: 'cf8b3e18-dacf-4e91-92e1-018035961003',
              thumbnail: 'radios',
              url: 'best-formbuilder'
            }
          ],
          [
            {
              type: 'flow.branch',
              title: 'Branching point 4',
              uuid: 'cf8b3e18-dacf-4e91-92e1-018035961003',
              thumbnail: 'branch',
              conditionals: [
                {
                  next: 'b5efc09c-ece7-45ae-b0b3-8a7905e25040',
                  expressions: [
                    {
                      question: 'What is the best form builder?',
                      operator: 'is not',
                      answer: 'MoJ'
                    }
                  ]
                },
                {
                  next: '0c022e95-0748-4dda-8ba5-12fd1d2f596b',
                  expressions: [
                    {
                      question: 'Otherwise',
                      operator: '',
                      answer: ''
                    }
                  ]
                }
              ]
            }
          ],
          [
            {
              type: 'page.singlequestion',
              title: 'Which Formbuilder is the best?',
              uuid: 'b5efc09c-ece7-45ae-b0b3-8a7905e25040',
              next: '0c022e95-0748-4dda-8ba5-12fd1d2f596b',
              thumbnail: 'text',
              url: 'which-formbuilder'
            }
          ],
          [
            {
              type: 'page.singlequestion',
              title: 'What would you like on your burger?',
              uuid: '0c022e95-0748-4dda-8ba5-12fd1d2f596b',
              next: '618b7537-b42b-4551-ae7d-053afa4d9ca9',
              thumbnail: 'checkboxes',
              url: 'burgers'
            }
          ],
          [
            {
              type: 'flow.branch',
              title: 'Branching point 5',
              uuid: '618b7537-b42b-4551-ae7d-053afa4d9ca9',
              thumbnail: 'branch',
              conditionals: [
                {
                  next: 'bc666714-c0a2-4674-afe5-faff2e20d847',
                  expressions: [
                    {
                      question: 'What would you like on your burger?',
                      operator: 'is',
                      answer: 'Beef, cheese, tomato'
                    }
                  ]
                },
                {
                  next: 'e2887f44-5e8d-4dc0-b1de-496ab6039430',
                  expressions: [
                    {
                      question: 'What would you like on your burger?',
                      operator: 'is not',
                      answer: 'Beef, cheese, tomato'
                    }
                  ]
                },
                {
                  next: 'dc7454f9-4186-48d7-b055-684d57bbcdc7',
                  expressions: [
                    {
                      question: 'Otherwise',
                      operator: '',
                      answer: ''
                    }
                  ]
                }
              ]
            }
          ],
          [
            {
              type: 'page.content',
              title: 'Global warming',
              uuid: 'bc666714-c0a2-4674-afe5-faff2e20d847',
              next: 'dc7454f9-4186-48d7-b055-684d57bbcdc7',
              thumbnail: 'content',
              url: 'global-warming'
            },
            {
              type: 'page.content',
              title: 'We love chickens',
              uuid: 'e2887f44-5e8d-4dc0-b1de-496ab6039430',
              next: 'dc7454f9-4186-48d7-b055-684d57bbcdc7',
              thumbnail: 'content',
              url: 'we-love-chickens'
            }
          ],
          [
            {
              type: 'page.singlequestion',
              title: 'What is the best marvel series?',
              uuid: 'dc7454f9-4186-48d7-b055-684d57bbcdc7',
              next: '84a347fc-8d4b-486a-9996-6a86fa9544c5',
              thumbnail: 'radios',
              url: 'marvel-series'
            }
          ],
          [
            {
              type: 'flow.branch',
              title: 'Branching point 6',
              uuid: '84a347fc-8d4b-486a-9996-6a86fa9544c5',
              thumbnail: 'branch',
              conditionals: [
                {
                  next: '2cc66e51-2c14-4023-86bf-ded49887cdb2',
                  expressions: [
                    {
                      question: 'What is the best marvel series?',
                      operator: 'is',
                      answer: 'The Falcon and the Winter Soldier'
                    }
                  ]
                },
                {
                  next: '2cc66e51-2c14-4023-86bf-ded49887cdb2',
                  expressions: [
                    {
                      question: 'What is the best marvel series?',
                      operator: 'is',
                      answer: 'Loki'
                    }
                  ]
                },
                {
                  next: 'f6c51f88-7be8-4cb7-bbfc-6c905727a051',
                  expressions: [
                    {
                      question: 'Do you like Star Wars?',
                      operator: 'is',
                      answer: 'Only on weekends'
                    },
                    {
                      question: 'What is the best marvel series?',
                      operator: 'is',
                      answer: 'WandaVision'
                    }
                  ]
                },
                {
                  next: '48357db5-7c06-4e85-94b1-5e1c9d8f39eb',
                  expressions: [
                    {
                      question: 'Otherwise',
                      operator: '',
                      answer: ''
                    }
                  ]
                }
              ]
            }
          ],
          [
            {
              type: 'page.content',
              title: 'Loki',
              uuid: '2cc66e51-2c14-4023-86bf-ded49887cdb2',
              next: '48357db5-7c06-4e85-94b1-5e1c9d8f39eb',
              thumbnail: 'content',
              url: 'marvel-quotes'
            },
            {
              type: 'spacer'
            },
            {
              type: 'page.content',
              title: 'Other quotes',
              uuid: 'f6c51f88-7be8-4cb7-bbfc-6c905727a051',
              next: '48357db5-7c06-4e85-94b1-5e1c9d8f39eb',
              thumbnail: 'content',
              url: 'other-quotes'
            }
          ],
          [
            {
              type: 'page.singlequestion',
              title: 'Select all Arnold Schwarzenegger quotes',
              uuid: '48357db5-7c06-4e85-94b1-5e1c9d8f39eb',
              next: '1079b5b8-abd0-4bf6-aaac-1f01e69e3b39',
              thumbnail: 'checkboxes',
              url: 'best-arnold-quote'
            }
          ],
          [
            {
              type: 'flow.branch',
              title: 'Branching point 7',
              uuid: '1079b5b8-abd0-4bf6-aaac-1f01e69e3b39',
              thumbnail: 'branch',
              conditionals: [
                {
                  next: '56e80942-d0a4-405a-85cd-bd1b100013d6',
                  expressions: [
                    {
                      question: 'Select all Arnold Schwarzenegger quotes',
                      operator: 'is',
                      answer: 'You are not you. You are me'
                    },
                    {
                      question: 'Select all Arnold Schwarzenegger quotes',
                      operator: 'is',
                      answer: 'Get to the chopper'
                    },
                    {
                      question: 'Select all Arnold Schwarzenegger quotes',
                      operator: 'is',
                      answer: 'You have been terminated'
                    }
                  ]
                },
                {
                  next: '6324cca4-7770-4765-89b9-1cdc41f49c8b',
                  expressions: [
                    {
                      question: 'Select all Arnold Schwarzenegger quotes',
                      operator: 'is',
                      answer: 'I am GROOT'
                    }
                  ]
                },
                {
                  next: '6324cca4-7770-4765-89b9-1cdc41f49c8b',
                  expressions: [
                    {
                      question: 'Select all Arnold Schwarzenegger quotes',
                      operator: 'is',
                      answer: 'Dance Off, Bro.'
                    }
                  ]
                },
                {
                  next: '941137d7-a1da-43fd-994a-98a4f9ea6d46',
                  expressions: [
                    {
                      question: 'Otherwise',
                      operator: '',
                      answer: ''
                    }
                  ]
                }
              ]
            }
          ],
          [
            {
              type: 'page.content',
              title: 'You are right',
              uuid: '56e80942-d0a4-405a-85cd-bd1b100013d6',
              next: 'e337070b-f636-49a3-a65c-f506675265f0',
              thumbnail: 'content',
              url: 'arnold-right-answers'
            },
            {
              type: 'page.content',
              title: 'You are wrong', # wrong answers, GOTG quotes
              uuid: '6324cca4-7770-4765-89b9-1cdc41f49c8b',
              next: 'e337070b-f636-49a3-a65c-f506675265f0',
              thumbnail: 'content',
              url: 'arnold-wrong-answers'
            },
            {
              type: 'spacer'
            },
            {
              type: 'page.content',
              title: 'You are wrong', # incomplete answers, Otherwise
              uuid: '941137d7-a1da-43fd-994a-98a4f9ea6d46',
              next: 'e337070b-f636-49a3-a65c-f506675265f0',
              thumbnail: 'content',
              url: 'arnold-incomplete-answers'
            }
          ],
          [
            {
              type: 'page.checkanswers',
              title: 'Check your answers',
              uuid: 'e337070b-f636-49a3-a65c-f506675265f0',
              next: '778e364b-9a7f-4829-8eb2-510e08f156a3',
              thumbnail: 'checkanswers',
              url: 'check-answers'
            }
          ],
          [
            {
              type: 'page.confirmation',
              title: 'Complaint sent',
              uuid: '778e364b-9a7f-4829-8eb2-510e08f156a3',
              next: '',
              thumbnail: 'confirmation',
              url: 'confirmation'
            }
          ]
        ]
      end

      it 'builds the service flow in the correct order and structure' do
        expect(pages_flow.build).to eq(expected_flow)
      end

      it 'does not duplicate any flow objects' do
        # Spacers don't have uuids
        flow_uuids = pages_flow.build.flatten.map { |flow| flow[:uuid] }.compact
        expect(flow_uuids.uniq.size).to eq(service.flow.size)
      end

      context 'with branching fixture 2' do
        let(:metadata) { metadata_fixture(:branching_2) }
        let(:expected_flow) do
          [
            [
              {
                type: 'page.start',
                title: 'Branching Fixture 2',
                uuid: 'cf6dc32f-502c-4215-8c27-1151a45735bb',
                next: '68fbb180-9a2a-48f6-9da6-545e28b8d35a',
                thumbnail: 'start',
                url: '/'
              }
            ],
            [
              {
                type: 'page.singlequestion',
                title: 'Page B',
                uuid: '68fbb180-9a2a-48f6-9da6-545e28b8d35a',
                next: '09e91fd9-7a46-4840-adbc-244d545cfef7',
                thumbnail: 'radios',
                url: 'page-b'
              }
            ],
            [
              {
                type: 'flow.branch',
                title: 'Branching point 1',
                uuid: '09e91fd9-7a46-4840-adbc-244d545cfef7',
                thumbnail: 'branch',
                conditionals: [
                  {
                    next: 'e8708909-922e-4eaf-87a5-096f7a713fcb',
                    expressions: [
                      {
                        question: 'Page B',
                        operator: 'is',
                        answer: 'Item 1'
                      }
                    ]
                  },
                  {
                    next: '3a584d15-6805-4a21-bc05-b61c3be47857',
                    expressions: [
                      {
                        question: 'Page B',
                        operator: 'is',
                        answer: 'Item 2'
                      }
                    ]
                  },
                  {
                    next: 'f475d6fd-0ea4-45d5-985e-e1a7c7a5b992',
                    expressions: [
                      {
                        question: 'Otherwise',
                        operator: '',
                        answer: ''
                      }
                    ]
                  }
                ]
              }
            ],
            [
              {
                type: 'page.singlequestion',
                title: 'Page C',
                uuid: 'e8708909-922e-4eaf-87a5-096f7a713fcb',
                next: '65a2e01a-57dc-4702-8e41-ed8f9921ac7d',
                thumbnail: 'text',
                url: 'page-c'
              },
              {
                type: 'page.singlequestion',
                title: 'Page G',
                uuid: '3a584d15-6805-4a21-bc05-b61c3be47857',
                next: '7a561e9f-f4f8-4d2e-a01e-4097fc3ccf1c',
                thumbnail: 'text',
                url: 'page-g'
              },
              {
                type: 'page.singlequestion',
                title: 'Page J',
                uuid: 'f475d6fd-0ea4-45d5-985e-e1a7c7a5b992',
                next: 'ffadeb22-063b-4e4f-9502-bd753c706b1d',
                thumbnail: 'radios',
                url: 'page-j'
              }
            ],
            [
              {
                type: 'page.singlequestion',
                title: 'Page D',
                uuid: '65a2e01a-57dc-4702-8e41-ed8f9921ac7d',
                next: '37a94466-97fa-427f-88b2-09b369435d0d',
                thumbnail: 'text',
                url: 'page-d'
              },
              {
                type: 'page.singlequestion',
                title: 'Page H',
                uuid: '7a561e9f-f4f8-4d2e-a01e-4097fc3ccf1c',
                next: '520fde26-8124-4c67-a550-cd38d2ef304d',
                thumbnail: 'text',
                url: 'page-h'
              },
              {
                type: 'flow.branch',
                title: 'Branching point 2',
                uuid: 'ffadeb22-063b-4e4f-9502-bd753c706b1d',
                thumbnail: 'branch',
                conditionals: [
                  {
                    next: 'be130ac1-f33d-4845-807d-89b23b90d205',
                    expressions: [
                      {
                        question: 'Page J',
                        operator: 'is',
                        answer: 'Item 1'
                      }
                    ]
                  },
                  {
                    next: 'd80a2225-63c3-4944-873f-504b61311a15',
                    expressions: [
                      {
                        question: 'Otherwise',
                        operator: '',
                        answer: ''
                      }
                    ]
                  }
                ]
              }
            ],
            [
              {
                type: 'page.singlequestion',
                title: 'Page E',
                uuid: '37a94466-97fa-427f-88b2-09b369435d0d',
                next: '13ecf9bd-5064-4cad-baf8-3dfa091928cb',
                thumbnail: 'text',
                url: 'page-e'
              },
              {
                type: 'page.singlequestion',
                title: 'Page I',
                uuid: '520fde26-8124-4c67-a550-cd38d2ef304d',
                next: 'e337070b-f636-49a3-a65c-f506675265f0',
                thumbnail: 'text',
                url: 'page-i'
              },
              {
                type: 'page.singlequestion',
                title: 'Page K',
                uuid: 'be130ac1-f33d-4845-807d-89b23b90d205',
                next: '2c7deb33-19eb-4569-86d6-462e3d828d87',
                thumbnail: 'text',
                url: 'page-k'
              },
              {
                type: 'page.singlequestion',
                title: 'Page M',
                uuid: 'd80a2225-63c3-4944-873f-504b61311a15',
                next: '393645a4-f037-4e75-8359-51f9b0e360fb',
                thumbnail: 'text',
                url: 'page-m'
              }
            ],
            [
              {
                type: 'page.singlequestion',
                title: 'Page F',
                uuid: '13ecf9bd-5064-4cad-baf8-3dfa091928cb',
                next: 'e337070b-f636-49a3-a65c-f506675265f0',
                thumbnail: 'text',
                url: 'page-f'
              },
              {
                type: 'spacer'
              },
              {
                type: 'page.singlequestion',
                title: 'Page L',
                uuid: '2c7deb33-19eb-4569-86d6-462e3d828d87',
                next: 'e337070b-f636-49a3-a65c-f506675265f0',
                thumbnail: 'text',
                url: 'page-l'
              },
              {
                type: 'page.singlequestion',
                title: 'Page N',
                uuid: '393645a4-f037-4e75-8359-51f9b0e360fb',
                next: 'e337070b-f636-49a3-a65c-f506675265f0',
                thumbnail: 'text',
                url: 'page-n'
              }
            ],
            [
              {
                type: 'page.checkanswers',
                title: 'Check your answers',
                uuid: 'e337070b-f636-49a3-a65c-f506675265f0',
                next: '778e364b-9a7f-4829-8eb2-510e08f156a3',
                thumbnail: 'checkanswers',
                url: 'check-answers'
              }
            ],
            [
              {
                type: 'page.confirmation',
                title: 'Complaint sent',
                uuid: '778e364b-9a7f-4829-8eb2-510e08f156a3',
                next: '',
                thumbnail: 'confirmation',
                url: 'confirmation'
              }
            ]
          ]
        end

        it 'builds the service flow in the correct order and structure' do
          expect(pages_flow.build).to eq(expected_flow)
        end
      end

      context 'with branching fixture 3' do
        let(:metadata) { metadata_fixture(:branching_3) }
        let(:expected_flow) do
          [
            [
              {
                type: 'page.start',
                title: 'Branching Fixture 3',
                uuid: 'cf6dc32f-502c-4215-8c27-1151a45735bb',
                next: '68fbb180-9a2a-48f6-9da6-545e28b8d35a',
                thumbnail: 'start',
                url: '/'
              }
            ],
            [
              {
                type: 'page.singlequestion',
                title: 'Page B',
                uuid: '68fbb180-9a2a-48f6-9da6-545e28b8d35a',
                next: '09e91fd9-7a46-4840-adbc-244d545cfef7',
                thumbnail: 'radios',
                url: 'page-b'
              }
            ],
            [
              {
                type: 'flow.branch',
                title: 'Branching point 1',
                uuid: '09e91fd9-7a46-4840-adbc-244d545cfef7',
                thumbnail: 'branch',
                conditionals: [
                  {
                    next: 'e8708909-922e-4eaf-87a5-096f7a713fcb',
                    expressions: [
                      {
                        question: 'Page B',
                        operator: 'is',
                        answer: 'Item 1'
                      }
                    ]
                  },
                  {
                    next: '3a584d15-6805-4a21-bc05-b61c3be47857',
                    expressions: [
                      {
                        question: 'Page B',
                        operator: 'is',
                        answer: 'Item 2'
                      }
                    ]
                  },
                  {
                    next: 'be130ac1-f33d-4845-807d-89b23b90d205',
                    expressions: [
                      {
                        question: 'Otherwise',
                        operator: '',
                        answer: ''
                      }
                    ]
                  }
                ]
              }
            ],
            [
              {
                type: 'page.singlequestion',
                title: 'Page C',
                uuid: 'e8708909-922e-4eaf-87a5-096f7a713fcb',
                next: '65a2e01a-57dc-4702-8e41-ed8f9921ac7d',
                thumbnail: 'text',
                url: 'page-c'
              },
              {
                type: 'page.singlequestion',
                title: 'Page G',
                uuid: '3a584d15-6805-4a21-bc05-b61c3be47857',
                next: '7a561e9f-f4f8-4d2e-a01e-4097fc3ccf1c',
                thumbnail: 'text',
                url: 'page-g'
              },
              {
                type: 'page.singlequestion',
                title: 'Page K',
                uuid: 'be130ac1-f33d-4845-807d-89b23b90d205',
                next: '2c7deb33-19eb-4569-86d6-462e3d828d87',
                thumbnail: 'text',
                url: 'page-k'
              }
            ],
            [
              {
                type: 'page.singlequestion',
                title: 'Page D',
                uuid: '65a2e01a-57dc-4702-8e41-ed8f9921ac7d',
                next: '37a94466-97fa-427f-88b2-09b369435d0d',
                thumbnail: 'text',
                url: 'page-d'
              },
              {
                type: 'page.singlequestion',
                title: 'Page H',
                uuid: '7a561e9f-f4f8-4d2e-a01e-4097fc3ccf1c',
                next: '520fde26-8124-4c67-a550-cd38d2ef304d',
                thumbnail: 'text',
                url: 'page-h'
              },
              {
                type: 'page.singlequestion',
                title: 'Page L',
                uuid: '2c7deb33-19eb-4569-86d6-462e3d828d87',
                next: 'e337070b-f636-49a3-a65c-f506675265f0',
                thumbnail: 'text',
                url: 'page-l'
              }
            ],
            [
              {
                type: 'page.singlequestion',
                title: 'Page E',
                uuid: '37a94466-97fa-427f-88b2-09b369435d0d',
                next: '13ecf9bd-5064-4cad-baf8-3dfa091928cb',
                thumbnail: 'text',
                url: 'page-e'
              },
              {
                type: 'page.singlequestion',
                title: 'Page I',
                uuid: '520fde26-8124-4c67-a550-cd38d2ef304d',
                next: 'e337070b-f636-49a3-a65c-f506675265f0',
                thumbnail: 'text',
                url: 'page-i'
              }
            ],
            [
              {
                type: 'page.singlequestion',
                title: 'Page F',
                uuid: '13ecf9bd-5064-4cad-baf8-3dfa091928cb',
                next: 'e337070b-f636-49a3-a65c-f506675265f0',
                thumbnail: 'text',
                url: 'page-f'
              }
            ],
            [
              {
                type: 'page.checkanswers',
                title: 'Check your answers',
                uuid: 'e337070b-f636-49a3-a65c-f506675265f0',
                next: '778e364b-9a7f-4829-8eb2-510e08f156a3',
                thumbnail: 'checkanswers',
                url: 'check-answers'
              }
            ],
            [
              {
                type: 'page.confirmation',
                title: 'Complaint sent',
                uuid: '778e364b-9a7f-4829-8eb2-510e08f156a3',
                next: '',
                thumbnail: 'confirmation',
                url: 'confirmation'
              }
            ]
          ]
        end

        it 'builds the service flow in the correct order and structure' do
          expect(pages_flow.build).to eq(expected_flow)
        end
      end

      context 'with branching fixture 4' do
        let(:metadata) { metadata_fixture(:branching_4) }
        let(:expected_flow) do
          [
            [
              {
                type: 'page.start',
                title: 'Branching Fixture 4',
                uuid: 'cf6dc32f-502c-4215-8c27-1151a45735bb',
                next: '68fbb180-9a2a-48f6-9da6-545e28b8d35a',
                thumbnail: 'start',
                url: '/'
              }
            ],
            [
              {
                type: 'page.singlequestion',
                title: 'Page B',
                uuid: '68fbb180-9a2a-48f6-9da6-545e28b8d35a',
                next: 'e8708909-922e-4eaf-87a5-096f7a713fcb',
                thumbnail: 'text',
                url: 'page-b'
              }
            ],
            [
              {
                type: 'page.singlequestion',
                title: 'Page C',
                uuid: 'e8708909-922e-4eaf-87a5-096f7a713fcb',
                next: '65a2e01a-57dc-4702-8e41-ed8f9921ac7d',
                thumbnail: 'text',
                url: 'page-c'
              }
            ],
            [
              {
                type: 'page.singlequestion',
                title: 'Page D',
                uuid: '65a2e01a-57dc-4702-8e41-ed8f9921ac7d',
                next: '09e91fd9-7a46-4840-adbc-244d545cfef7',
                thumbnail: 'radios',
                url: 'page-d'
              }
            ],
            [
              {
                type: 'flow.branch',
                title: 'Branching point 1',
                uuid: '09e91fd9-7a46-4840-adbc-244d545cfef7',
                thumbnail: 'branch',
                conditionals: [
                  {
                    next: '37a94466-97fa-427f-88b2-09b369435d0d',
                    expressions: [
                      {
                        question: 'Page D',
                        operator: 'is',
                        answer: 'Item 1'
                      }
                    ]
                  },
                  {
                    next: '520fde26-8124-4c67-a550-cd38d2ef304d',
                    expressions: [
                      {
                        question: 'Otherwise',
                        operator: '',
                        answer: ''
                      }
                    ]
                  }
                ]
              }
            ],
            [
              {
                type: 'page.singlequestion',
                title: 'Page E',
                uuid: '37a94466-97fa-427f-88b2-09b369435d0d',
                next: '13ecf9bd-5064-4cad-baf8-3dfa091928cb',
                thumbnail: 'text',
                url: 'page-e'
              },
              {
                type: 'page.singlequestion',
                title: 'Page I',
                uuid: '520fde26-8124-4c67-a550-cd38d2ef304d',
                next: 'f475d6fd-0ea4-45d5-985e-e1a7c7a5b992',
                thumbnail: 'text',
                url: 'page-i'
              }
            ],
            [
              {
                type: 'page.singlequestion',
                title: 'Page F',
                uuid: '13ecf9bd-5064-4cad-baf8-3dfa091928cb',
                next: '7a561e9f-f4f8-4d2e-a01e-4097fc3ccf1c',
                thumbnail: 'text',
                url: 'page-f'
              },
              {
                type: 'page.singlequestion',
                title: 'Page J',
                uuid: 'f475d6fd-0ea4-45d5-985e-e1a7c7a5b992',
                next: 'be130ac1-f33d-4845-807d-89b23b90d205',
                thumbnail: 'radios',
                url: 'page-j'
              }
            ],
            [
              {
                type: 'page.singlequestion',
                title: 'Page H',
                uuid: '7a561e9f-f4f8-4d2e-a01e-4097fc3ccf1c',
                next: 'e337070b-f636-49a3-a65c-f506675265f0',
                thumbnail: 'text',
                url: 'page-h'
              },
              {
                type: 'page.singlequestion',
                title: 'Page K',
                uuid: 'be130ac1-f33d-4845-807d-89b23b90d205',
                next: '2c7deb33-19eb-4569-86d6-462e3d828d87',
                thumbnail: 'text',
                url: 'page-k'
              }
            ],
            [
              {
                type: 'spacer'
              },
              {
                type: 'page.singlequestion',
                title: 'Page L',
                uuid: '2c7deb33-19eb-4569-86d6-462e3d828d87',
                next: 'e337070b-f636-49a3-a65c-f506675265f0',
                thumbnail: 'text',
                url: 'page-l'
              }
            ],
            [
              {
                type: 'page.checkanswers',
                title: 'Check your answers',
                uuid: 'e337070b-f636-49a3-a65c-f506675265f0',
                next: '778e364b-9a7f-4829-8eb2-510e08f156a3',
                thumbnail: 'checkanswers',
                url: 'check-answers'
              }
            ],
            [
              {
                type: 'page.confirmation',
                title: 'Complaint sent',
                uuid: '778e364b-9a7f-4829-8eb2-510e08f156a3',
                next: '',
                thumbnail: 'confirmation',
                url: 'confirmation'
              }
            ]
          ]
        end

        it 'builds the service flow in the correct order and structure' do
          expect(pages_flow.build).to eq(expected_flow)
        end
      end

      context 'with branching fixture 5' do
        let(:metadata) { metadata_fixture(:branching_5) }
        let(:expected_flow) do
          [
            [
              {
                type: 'page.start',
                title: 'Branching Fixture 5',
                uuid: 'cf6dc32f-502c-4215-8c27-1151a45735bb',
                next: '68fbb180-9a2a-48f6-9da6-545e28b8d35a',
                thumbnail: 'start',
                url: '/'
              }
            ],
            [
              {
                type: 'page.singlequestion',
                title: 'Page B',
                uuid: '68fbb180-9a2a-48f6-9da6-545e28b8d35a',
                next: '09e91fd9-7a46-4840-adbc-244d545cfef7',
                thumbnail: 'radios',
                url: 'page-b'
              }
            ],
            [
              {
                type: 'flow.branch',
                title: 'Branching point 1',
                uuid: '09e91fd9-7a46-4840-adbc-244d545cfef7',
                thumbnail: 'branch',
                conditionals: [
                  {
                    next: 'e8708909-922e-4eaf-87a5-096f7a713fcb',
                    expressions: [
                      {
                        question: 'Page B',
                        operator: 'is',
                        answer: 'Item 1'
                      }
                    ]
                  },
                  {
                    next: '3a584d15-6805-4a21-bc05-b61c3be47857',
                    expressions: [
                      {
                        question: 'Page B',
                        operator: 'is',
                        answer: 'Item 2'
                      }
                    ]
                  },
                  {
                    next: 'f475d6fd-0ea4-45d5-985e-e1a7c7a5b992',
                    expressions: [
                      {
                        question: 'Otherwise',
                        operator: '',
                        answer: ''
                      }
                    ]
                  }
                ]
              }
            ],
            [
              {
                type: 'page.singlequestion',
                title: 'Page C',
                uuid: 'e8708909-922e-4eaf-87a5-096f7a713fcb',
                next: '65a2e01a-57dc-4702-8e41-ed8f9921ac7d',
                thumbnail: 'text',
                url: 'page-c'
              },
              {
                type: 'page.singlequestion',
                title: 'Page G',
                uuid: '3a584d15-6805-4a21-bc05-b61c3be47857',
                next: 'e337070b-f636-49a3-a65c-f506675265f0',
                thumbnail: 'text',
                url: 'page-g'
              },
              {
                type: 'page.singlequestion',
                title: 'Page J',
                uuid: 'f475d6fd-0ea4-45d5-985e-e1a7c7a5b992',
                next: 'ffadeb22-063b-4e4f-9502-bd753c706b1d',
                thumbnail: 'radios',
                url: 'page-j'
              }
            ],
            [
              {
                type: 'page.singlequestion',
                title: 'Page D',
                uuid: '65a2e01a-57dc-4702-8e41-ed8f9921ac7d',
                next: '37a94466-97fa-427f-88b2-09b369435d0d',
                thumbnail: 'text',
                url: 'page-d'
              },
              {
                type: 'spacer'
              },
              {
                type: 'flow.branch',
                title: 'Branching point 2',
                uuid: 'ffadeb22-063b-4e4f-9502-bd753c706b1d',
                thumbnail: 'branch',
                conditionals: [
                  {
                    next: 'be130ac1-f33d-4845-807d-89b23b90d205',
                    expressions: [
                      {
                        question: 'Page J',
                        operator: 'is',
                        answer: 'Item 1'
                      }
                    ]
                  },
                  {
                    next: 'd80a2225-63c3-4944-873f-504b61311a15',
                    expressions: [
                      {
                        question: 'Otherwise',
                        operator: '',
                        answer: ''
                      }
                    ]
                  }
                ]
              }
            ],
            [
              {
                type: 'page.singlequestion',
                title: 'Page E',
                uuid: '37a94466-97fa-427f-88b2-09b369435d0d',
                next: '13ecf9bd-5064-4cad-baf8-3dfa091928cb',
                thumbnail: 'text',
                url: 'page-e'
              },
              {
                type: 'spacer'
              },
              {
                type: 'page.singlequestion',
                title: 'Page K',
                uuid: 'be130ac1-f33d-4845-807d-89b23b90d205',
                next: '2c7deb33-19eb-4569-86d6-462e3d828d87',
                thumbnail: 'text',
                url: 'page-k'
              },
              {
                type: 'page.singlequestion',
                title: 'Page M',
                uuid: 'd80a2225-63c3-4944-873f-504b61311a15',
                next: '393645a4-f037-4e75-8359-51f9b0e360fb',
                thumbnail: 'text',
                url: 'page-m'
              }
            ],
            [
              {
                type: 'page.singlequestion',
                title: 'Page F',
                uuid: '13ecf9bd-5064-4cad-baf8-3dfa091928cb',
                next: 'e337070b-f636-49a3-a65c-f506675265f0',
                thumbnail: 'text',
                url: 'page-f'
              },
              {
                type: 'spacer'
              },
              {
                type: 'page.singlequestion',
                title: 'Page L',
                uuid: '2c7deb33-19eb-4569-86d6-462e3d828d87',
                next: 'e337070b-f636-49a3-a65c-f506675265f0',
                thumbnail: 'text',
                url: 'page-l'
              },
              {
                type: 'page.singlequestion',
                title: 'Page N',
                uuid: '393645a4-f037-4e75-8359-51f9b0e360fb',
                next: 'e337070b-f636-49a3-a65c-f506675265f0',
                thumbnail: 'text',
                url: 'page-n'
              }
            ],
            [
              {
                type: 'page.checkanswers',
                title: 'Check your answers',
                uuid: 'e337070b-f636-49a3-a65c-f506675265f0',
                next: '778e364b-9a7f-4829-8eb2-510e08f156a3',
                thumbnail: 'checkanswers',
                url: 'check-answers'
              }
            ],
            [
              {
                type: 'page.confirmation',
                title: 'Complaint sent',
                uuid: '778e364b-9a7f-4829-8eb2-510e08f156a3',
                next: '',
                thumbnail: 'confirmation',
                url: 'confirmation'
              }
            ]
          ]
        end

        it 'builds the service flow in the correct order and structure' do
          expect(pages_flow.build).to eq(expected_flow)
        end
      end

      context 'with branching fixture 6' do
        let(:metadata) { metadata_fixture(:branching_6) }
        let(:expected_flow) do
          [
            [
              {
                type: 'page.start',
                title: 'Branching Fixture 6',
                uuid: 'cf6dc32f-502c-4215-8c27-1151a45735bb',
                next: '68fbb180-9a2a-48f6-9da6-545e28b8d35a',
                thumbnail: 'start',
                url: '/'
              }
            ],
            [
              {
                type: 'page.singlequestion',
                title: 'Page B',
                uuid: '68fbb180-9a2a-48f6-9da6-545e28b8d35a',
                next: 'e8708909-922e-4eaf-87a5-096f7a713fcb',
                thumbnail: 'text',
                url: 'page-b'
              }
            ],
            [
              {
                type: 'page.singlequestion',
                title: 'Page C',
                uuid: 'e8708909-922e-4eaf-87a5-096f7a713fcb',
                next: '65a2e01a-57dc-4702-8e41-ed8f9921ac7d',
                thumbnail: 'text',
                url: 'page-c'
              }
            ],
            [
              {
                type: 'page.singlequestion',
                title: 'Page D',
                uuid: '65a2e01a-57dc-4702-8e41-ed8f9921ac7d',
                next: '09e91fd9-7a46-4840-adbc-244d545cfef7',
                thumbnail: 'radios',
                url: 'page-d'
              }
            ],
            [
              {
                type: 'flow.branch',
                title: 'Branching point 1',
                uuid: '09e91fd9-7a46-4840-adbc-244d545cfef7',
                thumbnail: 'branch',
                conditionals: [
                  {
                    next: '37a94466-97fa-427f-88b2-09b369435d0d',
                    expressions: [
                      {
                        question: 'Page D',
                        operator: 'is',
                        answer: 'Item 1'
                      }
                    ]
                  },
                  {
                    next: '520fde26-8124-4c67-a550-cd38d2ef304d',
                    expressions: [
                      {
                        question: 'Otherwise',
                        operator: '',
                        answer: ''
                      }
                    ]
                  }
                ]
              }
            ],
            [
              {
                type: 'page.singlequestion',
                title: 'Page E',
                uuid: '37a94466-97fa-427f-88b2-09b369435d0d',
                next: 'e337070b-f636-49a3-a65c-f506675265f0',
                thumbnail: 'text',
                url: 'page-e'
              },
              {
                type: 'page.singlequestion',
                title: 'Page I',
                uuid: '520fde26-8124-4c67-a550-cd38d2ef304d',
                next: 'f475d6fd-0ea4-45d5-985e-e1a7c7a5b992',
                thumbnail: 'text',
                url: 'page-i'
              }
            ],
            [
              {
                type: 'spacer'
              },
              {
                type: 'page.singlequestion',
                title: 'Page J',
                uuid: 'f475d6fd-0ea4-45d5-985e-e1a7c7a5b992',
                next: 'be130ac1-f33d-4845-807d-89b23b90d205',
                thumbnail: 'radios',
                url: 'page-j'
              }
            ],
            [
              {
                type: 'spacer'
              },
              {
                type: 'page.singlequestion',
                title: 'Page K',
                uuid: 'be130ac1-f33d-4845-807d-89b23b90d205',
                next: '2c7deb33-19eb-4569-86d6-462e3d828d87',
                thumbnail: 'text',
                url: 'page-k'
              }
            ],
            [
              {
                type: 'spacer'
              },
              {
                type: 'page.singlequestion',
                title: 'Page L',
                uuid: '2c7deb33-19eb-4569-86d6-462e3d828d87',
                next: 'e337070b-f636-49a3-a65c-f506675265f0',
                thumbnail: 'text',
                url: 'page-l'
              }
            ],
            [
              {
                type: 'page.checkanswers',
                title: 'Check your answers',
                uuid: 'e337070b-f636-49a3-a65c-f506675265f0',
                next: '778e364b-9a7f-4829-8eb2-510e08f156a3',
                thumbnail: 'checkanswers',
                url: 'check-answers'
              }
            ],
            [
              {
                type: 'page.confirmation',
                title: 'Complaint sent',
                uuid: '778e364b-9a7f-4829-8eb2-510e08f156a3',
                next: '',
                thumbnail: 'confirmation',
                url: 'confirmation'
              }
            ]
          ]
        end

        it 'builds the service flow in the correct order and structure' do
          expect(pages_flow.build).to eq(expected_flow)
        end
      end

      context 'with branching fixture 7' do
        let(:metadata) { metadata_fixture(:branching_7) }
        let(:expected_flow) do
          [
            [
              {
                type: 'page.start',
                title: 'Branching Fixture 7',
                uuid: 'cf6dc32f-502c-4215-8c27-1151a45735bb',
                next: '68fbb180-9a2a-48f6-9da6-545e28b8d35a',
                thumbnail: 'start',
                url: '/'
              }
            ],
            [
              {
                type: 'page.singlequestion',
                title: 'Page B',
                uuid: '68fbb180-9a2a-48f6-9da6-545e28b8d35a',
                next: 'e8708909-922e-4eaf-87a5-096f7a713fcb',
                thumbnail: 'text',
                url: 'page-b'
              }
            ],
            [
              {
                type: 'page.singlequestion',
                title: 'Page C',
                uuid: 'e8708909-922e-4eaf-87a5-096f7a713fcb',
                next: '65a2e01a-57dc-4702-8e41-ed8f9921ac7d',
                thumbnail: 'text',
                url: 'page-c'
              }
            ],
            [
              {
                type: 'page.singlequestion',
                title: 'Page D',
                uuid: '65a2e01a-57dc-4702-8e41-ed8f9921ac7d',
                next: '09e91fd9-7a46-4840-adbc-244d545cfef7',
                thumbnail: 'radios',
                url: 'page-d'
              }
            ],
            [
              {
                type: 'flow.branch',
                title: 'Branching point 1',
                uuid: '09e91fd9-7a46-4840-adbc-244d545cfef7',
                thumbnail: 'branch',
                conditionals: [
                  {
                    next: '37a94466-97fa-427f-88b2-09b369435d0d',
                    expressions: [
                      {
                        question: 'Page D',
                        operator: 'is',
                        answer: 'Item 1'
                      }
                    ]
                  },
                  {
                    next: '520fde26-8124-4c67-a550-cd38d2ef304d',
                    expressions: [
                      {
                        question: 'Otherwise',
                        operator: '',
                        answer: ''
                      }
                    ]
                  }
                ]
              }
            ],
            [
              {
                type: 'page.singlequestion',
                title: 'Page E',
                uuid: '37a94466-97fa-427f-88b2-09b369435d0d',
                next: '13ecf9bd-5064-4cad-baf8-3dfa091928cb',
                thumbnail: 'text',
                url: 'page-e'
              },
              {
                type: 'page.singlequestion',
                title: 'Page I',
                uuid: '520fde26-8124-4c67-a550-cd38d2ef304d',
                next: 'ffadeb22-063b-4e4f-9502-bd753c706b1d',
                thumbnail: 'text',
                url: 'page-i'
              }
            ],
            [
              {
                type: 'spacer'
              },
              {
                type: 'flow.branch',
                title: 'Branching point 2',
                uuid: 'ffadeb22-063b-4e4f-9502-bd753c706b1d',
                thumbnail: 'branch',
                conditionals: [
                  {
                    next: '13ecf9bd-5064-4cad-baf8-3dfa091928cb',
                    expressions: [
                      {
                        question: 'Page D',
                        operator: 'is',
                        answer: 'Item 1'
                      }
                    ]
                  },
                  {
                    next: 'be130ac1-f33d-4845-807d-89b23b90d205',
                    expressions: [
                      {
                        question: 'Page D',
                        operator: 'is',
                        answer: 'Item 2'
                      }
                    ]
                  },
                  {
                    next: '3a584d15-6805-4a21-bc05-b61c3be47857',
                    expressions: [
                      {
                        question: 'Otherwise',
                        operator: '',
                        answer: ''
                      }
                    ]
                  }
                ]
              }
            ],
            [
              {
                type: 'page.singlequestion',
                title: 'Page F',
                uuid: '13ecf9bd-5064-4cad-baf8-3dfa091928cb',
                next: '7a561e9f-f4f8-4d2e-a01e-4097fc3ccf1c',
                thumbnail: 'text',
                url: 'page-f'
              },
              {
                type: 'page.singlequestion',
                title: 'Page K',
                uuid: 'be130ac1-f33d-4845-807d-89b23b90d205',
                next: '2c7deb33-19eb-4569-86d6-462e3d828d87',
                thumbnail: 'text',
                url: 'page-k'
              },
              {
                type: 'page.exit',
                title: 'Page G',
                uuid: '3a584d15-6805-4a21-bc05-b61c3be47857',
                next: '',
                thumbnail: 'exit'
                url: 'page-g'
              }
            ],
            [
              {
                type: 'page.singlequestion',
                title: 'Page H',
                uuid: '7a561e9f-f4f8-4d2e-a01e-4097fc3ccf1c',
                next: 'e337070b-f636-49a3-a65c-f506675265f0',
                thumbnail: 'text',
                url: 'page-h'
              },
              {
                type: 'page.singlequestion',
                title: 'Page L',
                uuid: '2c7deb33-19eb-4569-86d6-462e3d828d87',
                next: 'e337070b-f636-49a3-a65c-f506675265f0',
                thumbnail: 'text',
                url: 'page-l'
              }
            ],
            [
              {
                type: 'page.checkanswers',
                title: 'Check your answers',
                uuid: 'e337070b-f636-49a3-a65c-f506675265f0',
                next: '778e364b-9a7f-4829-8eb2-510e08f156a3',
                thumbnail: 'checkanswers',
                url: 'check-answers'
              }
            ],
            [
              {
                type: 'page.confirmation',
                title: 'Complaint sent',
                uuid: '778e364b-9a7f-4829-8eb2-510e08f156a3',
                next: '',
                thumbnail: 'confirmation',
                url: 'confirmation'
              }
            ]
          ]
        end

        it 'builds the service flow in the correct order and structure' do
          expect(pages_flow.build).to eq(expected_flow)
        end
      end

      context 'when page does not contain the component id referenced in a branch conditional' do
        let(:random_uuid) { SecureRandom.uuid }
        let(:metadata) do
          meta = metadata_fixture(:branching)
          meta['flow']['09e91fd9-7a46-4840-adbc-244d545cfef7']['next']['conditionals'][0]['expressions'][0]['component'] = random_uuid
          meta
        end
        let(:expected_message) do
          "Page 68fbb180-9a2a-48f6-9da6-545e28b8d35a does not contain component #{random_uuid}"
        end

        it 'raises a PageMissingComponentError' do
          expect { pages_flow.build }.to raise_error(PageMissingComponentError, expected_message)
        end
      end
    end
  end

  describe '#detached_flows' do
    context 'detaching a branch - branching fixture' do
      let(:metadata) do
        meta = metadata_fixture(:branching)
        # select all arnie quotes
        meta['flow']['48357db5-7c06-4e85-94b1-5e1c9d8f39eb']['next']['default'] = check_answers_uuid
        meta
      end
      let(:check_answers_uuid) { 'e337070b-f636-49a3-a65c-f506675265f0' }
      let(:expected_detached_flows) do
        [
          [
            [
              {
                type: 'flow.branch',
                title: 'Branching point 7',
                uuid: '1079b5b8-abd0-4bf6-aaac-1f01e69e3b39',
                thumbnail: 'branch',
                conditionals: [
                  {
                    next: '56e80942-d0a4-405a-85cd-bd1b100013d6',
                    expressions: [
                      {
                        question: 'Select all Arnold Schwarzenegger quotes',
                        operator: 'is',
                        answer: 'You are not you. You are me'
                      },
                      {
                        question: 'Select all Arnold Schwarzenegger quotes',
                        operator: 'is',
                        answer: 'Get to the chopper'
                      },
                      {
                        question: 'Select all Arnold Schwarzenegger quotes',
                        operator: 'is',
                        answer: 'You have been terminated'
                      }
                    ]
                  },
                  {
                    next: '6324cca4-7770-4765-89b9-1cdc41f49c8b',
                    expressions: [
                      {
                        question: 'Select all Arnold Schwarzenegger quotes',
                        operator: 'is',
                        answer: 'I am GROOT'
                      }
                    ]
                  },
                  {
                    next: '6324cca4-7770-4765-89b9-1cdc41f49c8b',
                    expressions: [
                      {
                        question: 'Select all Arnold Schwarzenegger quotes',
                        operator: 'is',
                        answer: 'Dance Off, Bro.'
                      }
                    ]
                  },
                  {
                    next: '941137d7-a1da-43fd-994a-98a4f9ea6d46',
                    expressions: [
                      {
                        question: 'Otherwise',
                        operator: '',
                        answer: ''
                      }
                    ]
                  }
                ]
              }
            ],
            [
              {
                type: 'page.content',
                title: 'You are right',
                uuid: '56e80942-d0a4-405a-85cd-bd1b100013d6',
                next: 'e337070b-f636-49a3-a65c-f506675265f0',
                thumbnail: 'content'
              },
              {
                type: 'page.content',
                title: 'You are wrong', # wrong answers, GOTG quotes
                uuid: '6324cca4-7770-4765-89b9-1cdc41f49c8b',
                next: 'e337070b-f636-49a3-a65c-f506675265f0',
                thumbnail: 'content'
              },
              {
                type: 'spacer'
              },
              {
                type: 'page.content',
                title: 'You are wrong', # incomplete answers, Otherwise
                uuid: '941137d7-a1da-43fd-994a-98a4f9ea6d46',
                next: 'e337070b-f636-49a3-a65c-f506675265f0',
                thumbnail: 'content'
              }
            ],
            [
              {
                type: 'pointer',
                title: 'Check your answers',
                uuid: 'e337070b-f636-49a3-a65c-f506675265f0'
              }
            ]
          ]
        ]
      end

      it 'generates the correct detached flows objects' do
        expect(pages_flow.detached_flows).to eq(expected_detached_flows)
      end
    end

    context 'detaching multiple flows - branching fixture 2' do
      let(:metadata) do
        meta = metadata_fixture(:branching_2)
        obj = meta['flow']['09e91fd9-7a46-4840-adbc-244d545cfef7'] # Branching Point 1
        # Detach Page G
        obj['next']['conditionals'] = [obj['next']['conditionals'].shift]
        # Detach Page J
        obj['next']['default'] = 'e337070b-f636-49a3-a65c-f506675265f0' # Check answers
        meta['flow']['09e91fd9-7a46-4840-adbc-244d545cfef7'] = obj
        meta
      end
      let(:check_answers_uuid) { 'e337070b-f636-49a3-a65c-f506675265f0' }
      let(:expected_detached_flows) do
        [
          [
            [
              {
                type: 'page.singlequestion',
                title: 'Page J',
                uuid: 'f475d6fd-0ea4-45d5-985e-e1a7c7a5b992',
                next: 'ffadeb22-063b-4e4f-9502-bd753c706b1d',
                thumbnail: 'radios'
              }
            ],
            [
              {
                type: 'flow.branch',
                title: 'Branching point 2',
                uuid: 'ffadeb22-063b-4e4f-9502-bd753c706b1d',
                thumbnail: 'branch',
                conditionals: [
                  {
                    next: 'be130ac1-f33d-4845-807d-89b23b90d205',
                    expressions: [
                      {
                        question: 'Page J',
                        operator: 'is',
                        answer: 'Item 1'
                      }
                    ]
                  },
                  {
                    next: 'd80a2225-63c3-4944-873f-504b61311a15',
                    expressions: [
                      {
                        question: 'Otherwise',
                        operator: '',
                        answer: ''
                      }
                    ]
                  }
                ]
              }
            ],
            [
              {
                type: 'page.singlequestion',
                title: 'Page K',
                uuid: 'be130ac1-f33d-4845-807d-89b23b90d205',
                next: '2c7deb33-19eb-4569-86d6-462e3d828d87',
                thumbnail: 'text'
              },
              {
                type: 'page.singlequestion',
                title: 'Page M',
                uuid: 'd80a2225-63c3-4944-873f-504b61311a15',
                next: '393645a4-f037-4e75-8359-51f9b0e360fb',
                thumbnail: 'text'
              }
            ],
            [
              {
                type: 'page.singlequestion',
                title: 'Page L',
                uuid: '2c7deb33-19eb-4569-86d6-462e3d828d87',
                next: 'e337070b-f636-49a3-a65c-f506675265f0',
                thumbnail: 'text'
              },
              {
                type: 'page.singlequestion',
                title: 'Page N',
                uuid: '393645a4-f037-4e75-8359-51f9b0e360fb',
                next: 'e337070b-f636-49a3-a65c-f506675265f0',
                thumbnail: 'text'
              }
            ],
            [
              {
                type: 'pointer',
                title: 'Check your answers',
                uuid: 'e337070b-f636-49a3-a65c-f506675265f0'
              }
            ]
          ],
          [
            [
              {
                type: 'page.singlequestion',
                title: 'Page G',
                uuid: '3a584d15-6805-4a21-bc05-b61c3be47857',
                next: '7a561e9f-f4f8-4d2e-a01e-4097fc3ccf1c',
                thumbnail: 'text'
              }
            ],
            [
              {
                type: 'page.singlequestion',
                title: 'Page H',
                uuid: '7a561e9f-f4f8-4d2e-a01e-4097fc3ccf1c',
                next: '520fde26-8124-4c67-a550-cd38d2ef304d',
                thumbnail: 'text'
              }
            ],
            [
              {
                type: 'page.singlequestion',
                title: 'Page I',
                uuid: '520fde26-8124-4c67-a550-cd38d2ef304d',
                next: 'e337070b-f636-49a3-a65c-f506675265f0',
                thumbnail: 'text'
              }
            ],
            [
              {
                type: 'pointer',
                title: 'Check your answers',
                uuid: 'e337070b-f636-49a3-a65c-f506675265f0'
              }
            ]
          ]
        ]
      end

      it 'generates the correct detached flows objects' do
        expect(pages_flow.detached_flows).to eq(expected_detached_flows)
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
        next: 'cf8b3e18-dacf-4e91-92e1-018035961003',
        thumbnail: 'radios',
        url: 'best-formbuilder'
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
          thumbnail: 'branch',
          conditionals: [
            {
              next: 'e8708909-922e-4eaf-87a5-096f7a713fcb',
              expressions: [
                {
                  question: 'Do you like Star Wars?',
                  operator: 'is',
                  answer: 'Only on weekends'
                }
              ]
            },
            {
              next: '0b297048-aa4d-49b6-ac74-18e069118185',
              expressions: [
                {
                  question: 'Otherwise',
                  operator: '',
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
          thumbnail: 'branch',
          conditionals: [
            {
              next: 'bc666714-c0a2-4674-afe5-faff2e20d847',
              expressions: [
                {
                  question: 'What would you like on your burger?',
                  operator: 'is',
                  answer: 'Beef, cheese, tomato'
                }
              ]
            },
            {
              next: 'e2887f44-5e8d-4dc0-b1de-496ab6039430',
              expressions: [
                {
                  question: 'What would you like on your burger?',
                  operator: 'is not',
                  answer: 'Beef, cheese, tomato'
                }
              ]
            },
            {
              next: 'dc7454f9-4186-48d7-b055-684d57bbcdc7',
              expressions: [
                {
                  question: 'Otherwise',
                  operator: '',
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
          thumbnail: 'branch',
          conditionals: [
            {
              next: '56e80942-d0a4-405a-85cd-bd1b100013d6',
              expressions: [
                {
                  question: 'Select all Arnold Schwarzenegger quotes',
                  operator: 'is',
                  answer: 'You are not you. You are me'
                },
                {
                  question: 'Select all Arnold Schwarzenegger quotes',
                  operator: 'is',
                  answer: 'Get to the chopper'
                },
                {
                  question: 'Select all Arnold Schwarzenegger quotes',
                  operator: 'is',
                  answer: 'You have been terminated'
                }
              ]
            },
            {
              next: '941137d7-a1da-43fd-994a-98a4f9ea6d46',
              expressions: [
                {
                  question: 'Otherwise',
                  operator: '',
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
          thumbnail: 'branch',
          conditionals: [
            {
              next: '56e80942-d0a4-405a-85cd-bd1b100013d6',
              expressions: [
                {
                  question: 'Select all Arnold Schwarzenegger quotes',
                  operator: 'is',
                  answer: 'You are not you. You are me'
                },
                {
                  question: 'Select all Arnold Schwarzenegger quotes',
                  operator: 'is',
                  answer: 'Get to the chopper'
                },
                {
                  question: 'Select all Arnold Schwarzenegger quotes',
                  operator: 'is',
                  answer: 'You have been terminated'
                }
              ]
            },
            {
              next: '6324cca4-7770-4765-89b9-1cdc41f49c8b',
              expressions: [
                {
                  question: 'Select all Arnold Schwarzenegger quotes',
                  operator: 'is',
                  answer: 'I am GROOT'
                }
              ]
            },
            {
              next: '6324cca4-7770-4765-89b9-1cdc41f49c8b',
              expressions: [
                {
                  question: 'Select all Arnold Schwarzenegger quotes',
                  operator: 'is',
                  answer: 'Dance Off, Bro.'
                }
              ]
            },
            {
              next: '941137d7-a1da-43fd-994a-98a4f9ea6d46',
              expressions: [
                {
                  question: 'Otherwise',
                  operator: '',
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
