RSpec.describe PageUpdater do
  def find_page_uuid(url, meta)
    all_pages = meta['pages'] + meta['standalone_pages']
    all_pages.find { |page| page['url'] == url }['_uuid']
  end

  subject(:page) { described_class.new(attributes) }
  let(:service_id) { service.service_id }
  let(:updated_metadata) do
    metadata = service_metadata.deep_dup
    metadata['pages'][0] = metadata['pages'][0].merge(attributes_to_update)
    metadata
  end
  let(:version) { double(errors?: false, errors: [], metadata: updated_metadata) }

  before do
    expect(
      MetadataApiClient::Version
    ).to receive(:create).with(
      service_id:,
      payload: updated_metadata
    ).and_return(version)

    allow(SecureRandom).to receive(:uuid).and_return(
      "Dead or alive you're coming with me",
      'KNOCK KNOCK',
      'Hasta la vista, baby'
    )
  end

  describe '#update' do
    let(:valid) { true }
    let(:attributes) do
      {
        uuid: service_metadata['pages'][0]['_uuid'],
        service_id: service.service_id,
        latest_metadata: service_metadata
      }.merge(attributes_to_update)
    end

    context 'page attributes' do
      let(:page_url) { '/' }
      let(:attributes_to_update) do
        {
          section_heading: 'Some important section heading',
          heading: 'Some super important heading',
          lede: 'This is a lede',
          body: 'And what of the Rebellion?',
          before_you_start: "Don't try to frighten us with your sorcerer's ways, Lord Vader."
        }.stringify_keys
      end

      it 'updates the page metadata' do
        updated_page = page.update['pages'][0]
        expect(updated_page).to include(attributes_to_update)
      end

      it 'creates valid page metadata' do
        updated_page = page.update['pages'][0]
        expect(
          MetadataPresenter::ValidateSchema.validate(
            updated_page, 'page.start'
          )
        ).to be(valid)
      end

      it 'creates valid service metadata' do
        expect(
          MetadataPresenter::ValidateSchema.validate(
            page.update, 'service.base'
          )
        ).to be(valid)
      end
    end

    context 'when updating attributes and adding new components' do
      context 'when there are no components on the page' do
        context 'add to components collection' do
          let(:fixture) { metadata_fixture(:no_component_page) }
          let(:page_url) { 'confirmation' }
          let(:expected_created_component) do
            ActiveSupport::HashWithIndifferentAccess.new({
              '_id': 'confirmation_content_1',
              '_type': 'content',
              '_uuid': "Dead or alive you're coming with me",
              'content': '[Optional content]',
              'name': 'confirmation_content_1'
            })
          end
          let(:expected_updated_page) do
            {
              '_id' => 'page._confirmation',
              '_type' => 'page.confirmation',
              '_uuid' => 'b238a22f-c180-48d0-a7d9-8aad2036f1f2',
              'body' => "You'll receive a confirmation email",
              'heading' => 'Complaint sent',
              'lede' => 'Updated lede',
              'url' => 'confirmation',
              'components' => [expected_created_component]
            }
          end
          let(:updated_metadata) do
            metadata = fixture.deep_dup
            metadata['pages'][-1] = metadata['pages'][-1].merge(expected_updated_page)
            metadata
          end
          let(:attributes) do
            ActiveSupport::HashWithIndifferentAccess.new({
              uuid: find_page_uuid('confirmation', fixture),
              service_id: service.service_id,
              latest_metadata: fixture,
              actions: { add_component: 'content', component_collection: 'components' },
              lede: 'Updated lede'
            })
          end

          it 'updates the page metadata' do
            page.update['pages'][-1]
            expect(
              page.component_added.to_h.stringify_keys
            ).to eq(expected_created_component)
          end
        end
      end

      context 'when there are existing components to the page' do
        context 'when add a new component type' do
          let(:new_component) do
            {
              '_id' => 'star-wars-knowledge_number_1',
              '_type' => 'number',
              '_uuid' => "Dead or alive you're coming with me",
              'errors' => {},
              'hint' => '',
              'label' => 'Question',
              'name' => 'star-wars-knowledge_number_1',
              'validation' => { 'number' => true, 'required' => true },
              'width_class_input' => '10'
            }
          end
          let(:updated_metadata) do
            metadata = service_metadata.deep_dup
            page = metadata['pages'].find do |fixture_page|
              fixture_page['url'] == 'star-wars-knowledge'
            end

            page['components'] = page['components'].push(new_component)
            metadata
          end
          let(:attributes) do
            ActiveSupport::HashWithIndifferentAccess.new({
              service_id: service.service_id,
              latest_metadata: service_metadata,
              uuid: find_page_uuid('star-wars-knowledge', updated_metadata),
              actions: { add_component: 'number', component_collection: 'components' }
            })
          end

          it 'add new component' do
            page.update['pages']
            expect(
              page.component_added.to_h.stringify_keys
            ).to eq(new_component)
          end
        end

        context 'when add existing input components' do
          let(:new_component) do
            {
              '_id' => 'star-wars-knowledge_text_2',
              '_type' => 'text',
              '_uuid' => "Dead or alive you're coming with me",
              'errors' => {},
              'hint' => '',
              'label' => 'Question',
              'name' => 'star-wars-knowledge_text_2',
              'validation' => { 'required' => true }
            }
          end
          let(:updated_metadata) do
            metadata = service_metadata.deep_dup
            page = metadata['pages'].find do |fixture_page|
              fixture_page['url'] == 'star-wars-knowledge'
            end

            page['components'] = page['components'].push(new_component)
            metadata
          end
          let(:attributes) do
            ActiveSupport::HashWithIndifferentAccess.new({
              service_id: service.service_id,
              latest_metadata: service_metadata,
              uuid: find_page_uuid('star-wars-knowledge', updated_metadata),
              actions: { add_component: 'text', component_collection: 'components' }
            })
          end

          it 'add new component' do
            page.update['pages']
            expect(
              page.component_added.to_h.stringify_keys
            ).to eq(new_component)
          end
        end

        context 'when add existing collection component' do
          let(:new_component) do
            {
              '_id' => 'star-wars-knowledge_radios_2',
              '_type' => 'radios',
              '_uuid' => "Dead or alive you're coming with me",
              'errors' => {},
              'hint' => '',
              'items' => [
                {
                  '_id' => 'star-wars-knowledge_radios_2_item_1',
                  '_type' => 'radio',
                  '_uuid' => 'KNOCK KNOCK',
                  'hint' => '',
                  'label' => 'Option',
                  'value' => 'value-1'
                },
                {
                  '_id' => 'star-wars-knowledge_radios_2_item_2',
                  '_type' => 'radio',
                  '_uuid' => 'Hasta la vista, baby',
                  'hint' => '',
                  'label' => 'Option',
                  'value' => 'value-2'
                }
              ],
              'name' => 'star-wars-knowledge_radios_2',
              'legend' => 'Question',
              'validation' => { 'required' => true }
            }
          end
          let(:updated_metadata) do
            metadata = service_metadata.deep_dup
            page = metadata['pages'].find do |fixture_page|
              fixture_page['url'] == 'star-wars-knowledge'
            end

            page['components'] = page['components'].push(new_component)
            metadata
          end
          let(:attributes) do
            ActiveSupport::HashWithIndifferentAccess.new({
              service_id: service.service_id,
              latest_metadata: service_metadata,
              uuid: find_page_uuid('star-wars-knowledge', updated_metadata),
              actions: { add_component: 'radios', component_collection: 'components' }
            })
          end

          it 'add new component' do
            page.update['pages']
            expect(
              page.component_added.to_h.stringify_keys
            ).to eq(new_component)
          end
        end

        context 'add to extra components collection' do
          let(:fixture) { metadata_fixture(:version) }
          let(:page_url) { 'check-answers' }
          let(:expected_created_component) do
            ActiveSupport::HashWithIndifferentAccess.new({
              '_id': 'check-answers_content_3',
              '_type': 'content',
              '_uuid' => "Dead or alive you're coming with me",
              'content': '[Optional content]',
              'name': 'check-answers_content_3'
            })
          end
          let(:expected_updated_page) do
            metadata = fixture.deep_dup
            metadata['pages'][-2]['extra_components'].push(expected_created_component)
            metadata['pages'][-2]
          end
          let(:updated_metadata) do
            metadata = fixture.deep_dup
            metadata['pages'][-2] = metadata['pages'][-2].merge(expected_updated_page)
            metadata
          end
          let(:attributes) do
            ActiveSupport::HashWithIndifferentAccess.new({
              uuid: find_page_uuid('check-answers', updated_metadata),
              service_id: service.service_id,
              latest_metadata: fixture,
              actions: { add_component: 'content', component_collection: 'extra_components' }
            })
          end

          it 'updates the page metadata' do
            page.update['pages'][-2]
            expect(
              page.component_added.to_h.stringify_keys
            ).to eq(expected_created_component)
          end
        end
      end
    end

    context 'when receiving component with items without UUID' do
      let(:page_url) { 'do-you-like-star-wars' }
      let(:attributes) do
        {
          uuid: find_page_uuid('do-you-like-star-wars', service_metadata),
          service_id: service.service_id,
          latest_metadata: service_metadata
        }.merge(attributes_to_update)
      end
      let(:attributes_to_update) do
        {
          'components' => [
            '_uuid' => 'ac41be35-914e-4b22-8683-f5477716b7d4',
            'items' => [
              {
                '_uuid' => ''
              },
              {
                '_uuid' => ''
              },
              {
                '_uuid' => ''
              },
              {
                '_uuid' => nil
              },
              {
                '_uuid' => nil
              }
            ]
          ]
        }.stringify_keys
      end

      before do
        # we just want to test the metadata generated
        RSpec::Mocks.space.proxy_for(MetadataApiClient::Version).reset

        RSpec::Mocks.space.proxy_for(SecureRandom).reset

        allow(SecureRandom).to receive(:uuid).and_return(
          'Captain Insano shows no mercy',
          'No, You are wrong Colonel Sanders',
          'Now thats what I call high quality H2O',
          'Once again, I am not quite sure what that means',
          'You can do it'
        )
      end
      let(:updated_page) do
        MetadataPresenter::Service.new(
          page.metadata
        ).find_page_by_url(page_url)
      end
      let(:uuids) do
        updated_page.to_h[:components][0]['items'].map do |item|
          item['_uuid']
        end
      end

      it 'updates the page metadata inserting new UUIDs' do
        expect(uuids).to eq(
          [
            'Captain Insano shows no mercy',
            'No, You are wrong Colonel Sanders',
            'Now thats what I call high quality H2O',
            'Once again, I am not quite sure what that means',
            'You can do it'
          ]
        )
      end
    end

    context 'when receiving component / items with duplicated UUID' do
      let(:page_url) { 'do-you-like-star-wars' }
      let(:attributes) do
        {
          uuid: find_page_uuid('do-you-like-star-wars', service_metadata),
          service_id: service.service_id,
          latest_metadata: service_metadata
        }.merge(attributes_to_update)
      end
      let(:attributes_to_update) do
        {
          'components' => [
            '_uuid' => 'ac41be35-914e-4b22-8683-f5477716b7d4',
            'items' => [
              {
                '_uuid' => 'c5571937-9388-4411-b5fa-34ddf9bc4ca0'
              },
              {
                '_uuid' => '67160ff1-6f7c-43a8-8bf6-49b3d5f450f6'
              },
              {
                '_uuid' => 'ac41be35-914e-4b22-8683-f5477716b7d4'
              },
              {
                '_uuid' => 'ac41be35-914e-4b22-8683-f5477716b7d4'
              },
              {
                '_uuid' => 'ac41be35-914e-4b22-8683-f5477716b7d4'
              }
            ]
          ]
        }.stringify_keys
      end

      before do
        # we just want to test the metadata generated
        RSpec::Mocks.space.proxy_for(MetadataApiClient::Version).reset

        allow(SecureRandom).to receive(:uuid).and_return(
          'Captain Insano shows no mercy',
          'No, You are wrong Colonel Sanders',
          'Now thats what I call high quality H2O'
        )
      end

      it 'updates the page metadata replacing duplicated UUIDs' do
        updated_page = MetadataPresenter::Service.new(
          page.metadata
        ).find_page_by_url(page_url)
        uuids = updated_page.to_h[:components][0]['items'].map { |item| item['_uuid'] }
        expect(uuids).to eq(
          [
            'c5571937-9388-4411-b5fa-34ddf9bc4ca0',
            '67160ff1-6f7c-43a8-8bf6-49b3d5f450f6',
            'Captain Insano shows no mercy',
            'No, You are wrong Colonel Sanders',
            'Now thats what I call high quality H2O'
          ]
        )
      end
    end

    context 'when updating attributes for standalone pages' do
      let(:fixture) { metadata_fixture(:version) }
      let(:page_url) { 'privacy' }

      let(:expected_updated_page) do
        {
          '_id' => 'page.privacy',
          '_type' => 'page.standalone',
          '_uuid' => '4b86fe8c-7723-4cce-9378-7b2510279e04',
          'body' => 'Some joke about the cookie monster',
          'heading' => 'Privacy notice',
          'url' => 'privacy',
          'components' => []
        }
      end

      let(:updated_metadata) do
        metadata = fixture.deep_dup
        metadata['standalone_pages'].each_with_index do |page, index|
          if page['url'] == page_url
            metadata['standalone_pages'][index] = page.merge(expected_updated_page)
          end
        end
        metadata
      end

      let(:attributes) do
        ActiveSupport::HashWithIndifferentAccess.new({
          uuid: find_page_uuid('privacy', updated_metadata),
          service_id: service.service_id,
          latest_metadata: fixture
        }.merge(attributes_to_update))
      end

      let(:attributes_to_update) do
        {
          body: 'Some joke about the cookie monster'
        }.stringify_keys
      end

      it 'updates the page metadata' do
        update = page.update
        expect(
          update['standalone_pages'].find { |page| page['url'] == page_url }
        ).to eq(expected_updated_page)
      end
    end

    context 'when removing the cannoli (aka a content component)' do
      let(:attributes_to_update) do
        {
          uuid: find_page_uuid('check-answers', updated_metadata),
          actions: { delete_components: [uuid] }
        }
      end

      context 'removing from regular components' do
        let(:uuid) { 'b065ff4f-90c5-4ba2-b4ac-c984a9dd2470' }
        let(:updated_metadata) do
          metadata = service_metadata.deep_dup
          metadata['pages'][-2]['components'] = []
          metadata
        end

        it 'removes the correct component' do
          update = page.update
          page = update['pages'].find { |p| p['url'] == 'check-answers' }
          component_uuids = page['components'].map do |component|
            component['_uuid']
          end

          expect(component_uuids).to_not include(uuid)
        end
      end

      context 'removing from extra_components' do
        let(:uuid) { '3e6ef27e-91a6-402f-8291-b7ce669e824e' }
        let(:updated_metadata) do
          metadata = service_metadata.deep_dup
          metadata['pages'][-2]['extra_components'] = []
          metadata
        end

        it 'removes the correct component' do
          update = page.update
          page = update['pages'].find { |p| p['url'] == 'check-answers' }
          component_uuids = page['components'].map do |component|
            component['_uuid']
          end

          expect(component_uuids).to_not include(uuid)
        end
      end
    end
  end
end
