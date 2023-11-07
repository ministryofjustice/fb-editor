RSpec.describe NewServiceGenerator do
  describe '#to_metadata' do
    let(:valid) { true }

    context 'valid service metadata' do
      let(:service_name) { 'Razorback' }
      let(:current_user) { double(id: '1234') }
      let(:service_metadata) do
        NewServiceGenerator.new(
          service_name:,
          current_user:
        ).to_metadata
      end
      let(:start_page_uuid) { service_metadata['pages'][0]['_uuid'] }
      let(:cya_page_uuid) { service_metadata['pages'][1]['_uuid'] }
      let(:confirmation_page_uuid) { service_metadata['pages'][2]['_uuid'] }
      let(:expected_service_flow) do
        {
          start_page_uuid => {
            '_type': 'flow.page',
            'next': {
              'default': cya_page_uuid
            }
          },
          cya_page_uuid => {
            '_type': 'flow.page',
            'next': {
              'default': confirmation_page_uuid
            }
          },
          confirmation_page_uuid => {
            '_type': 'flow.page',
            'next': {
              'default': ''
            }
          }
        }
      end

      it 'creates a valid service metadata' do
        expect(
          MetadataPresenter::ValidateSchema.validate(
            service_metadata, 'service.base'
          )
        ).to be(valid)
      end

      it 'creates start page' do
        expect(service_metadata['pages']).to be_present
        expect(service_metadata['pages'][0]).to include(
          '_type' => 'page.start',
          'url' => '/'
        )
      end

      it 'creates check answers page' do
        expect(service_metadata['pages']).to be_present
        expect(service_metadata['pages'][1]).to include(
          '_type' => 'page.checkanswers',
          'url' => 'check-answers'
        )
      end

      it 'creates confirmation page' do
        expect(service_metadata['pages']).to be_present
        expect(service_metadata['pages'][2]).to include(
          '_type' => 'page.confirmation',
          'url' => 'form-sent'
        )
      end

      it 'creates the page flow object' do
        expect(service_metadata['flow']).to be_present
        expect(service_metadata['flow']).to eq(expected_service_flow)
      end

      it 'creates the default footer pages' do
        expect(service_metadata['standalone_pages'].count).to eq(3)

        urls = service_metadata['standalone_pages'].map { |page| page['url'] }
        I18n.t('presenter.footer').each do |_, page|
          expect(urls).to include(page[:url])
        end
      end

      it 'creates valid pages' do
        all_pages = service_metadata['pages'] + service_metadata['standalone_pages']
        all_pages.each do |page|
          expect(
            MetadataPresenter::ValidateSchema.validate(page, page['_type'])
          ).to be(valid)
        end
      end
    end

    context 'validation of page types in the flow' do
      context 'when an invalid page type is used' do
        let(:test_metadata) do
          service_metadata.dup.merge(
            'pages' => [
              {
                '_type' => 'page.foobar',
                '_id' => 'page.foobar',
                '_uuid' => SecureRandom.uuid,
                'url' => '/something'
              }
            ]
          )
        end

        it 'raises a schema validation error' do
          expect {
            MetadataPresenter::ValidateSchema.validate(test_metadata, 'service.base')
          }.to raise_error(JSON::Schema::ValidationError)
        end
      end

      %w[
        start exit checkanswers confirmation content singlequestion multiplequestions
      ].each do |page_type|
        context "when a page of type 'page.#{page_type}' is used" do
          let(:test_metadata) do
            service_metadata.dup.merge(
              'pages' => [
                {
                  '_type' => "page.#{page_type}",
                  '_id' => "page.#{page_type}_foobar",
                  '_uuid' => SecureRandom.uuid,
                  'url' => '/something',
                  # NOTE: some pages does not require some or all of the following
                  # but for the sake of this test, we add them. This test is really about
                  # validating the types of pages allowed in the `pages` metadata attribute.
                  'heading' => 'Hello world',
                  'send_heading' => 'anything',
                  'send_body' => 'anything',
                  'components' => []
                }
              ]
            )
          end

          it 'validates the service.base' do
            expect(
              MetadataPresenter::ValidateSchema.validate(test_metadata, 'service.base')
            ).to be(valid)
          end
        end
      end
    end

    context 'invalid metadata' do
      it 'raises a schema validation error' do
        expect {
          MetadataPresenter::ValidateSchema.validate(
            { foo: 'bar' }, 'service.base'
          )
        }.to raise_error(JSON::Schema::ValidationError)
      end
    end
  end
end
