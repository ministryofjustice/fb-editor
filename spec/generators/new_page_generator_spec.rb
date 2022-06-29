RSpec.describe NewPageGenerator do
  subject(:generator) do
    described_class.new(
      page_type: page_type,
      page_url: page_url,
      component_type: component_type,
      latest_metadata: latest_metadata,
      add_page_after: add_page_after,
      page_uuid: page_uuid,
      conditional_uuid: conditional_uuid
    )
  end
  let(:service_metadata) { latest_metadata }
  let(:add_page_after) { nil }
  let(:conditional_uuid) { nil }
  let(:page_uuid) { SecureRandom.uuid }
  let(:valid) { true }

  describe '#to_metadata' do
    let(:page_type) { 'singlequestion' }
    let(:page_url) { 'home-one' }
    let(:component_type) { 'text' }
    let(:page_attributes) do
      {
        'url' => page_url,
        '_id' => 'page.home-one',
        '_type' => 'page.singlequestion',
        '_uuid' => 'mandalorian-123',
        'section_heading' => '',
        'heading' => '',
        'lede' => '',
        'body' => 'Body section',
        'components' => [
          {
            '_id' => "#{page_url}_#{component_type}_1",
            '_type' => 'text',
            '_uuid' => 'mandalorian-123',
            'errors' => {},
            'hint' => '',
            'label' => 'Question',
            'name' => "#{page_url}_#{component_type}_1",
            'validation' => {
              'required' => true
            }
          }
        ]
      }
    end

    before do
      allow(SecureRandom).to receive(:uuid).and_return('mandalorian-123')
    end

    context 'when only start page exists' do
      let(:latest_metadata) { metadata_fixture(:service) }

      it 'create valid update service metadata' do
        expect(
          MetadataPresenter::ValidateSchema.validate(
            generator.to_metadata, 'service.base'
          )
        ).to be(valid)
      end

      it 'generates page attributes' do
        expect(generator.to_metadata['pages']).to_not be_blank
        expect(generator.to_metadata['pages'].last).to include(
          'url' => page_url,
          '_uuid' => 'mandalorian-123'
        )
      end

      it 'generates the new component metadata' do
        generated_page = generator.to_metadata['pages'].last
        expect(generated_page['components']).to_not be_blank
        expect(generated_page['components'].last).to include(
          '_type' => component_type
        )
      end
    end

    context 'when there is more than just a start page' do
      let(:latest_metadata) { metadata_fixture(:version) }

      context 'when inserting page after a given page' do
        # this is the third page so the new page should be the fourth page
        let(:add_page_after) do
          page = service.find_page_by_url('email-address')
          page.uuid
        end
        let(:expected_default_next) do
          # parent-name. email-address's page old default next
          '4b8c6bf3-878a-4446-9198-48351b3e2185'
        end
        let(:expected_flow_metadata) do
          {
            '_type' => 'flow.page',
            'next' => {
              'default' => expected_default_next
            }
          }
        end

        it 'adds new page after the given page' do
          pages = generator.to_metadata['pages']
          expect(pages).to_not be_blank
          expect(pages[3]).to include(page_attributes)
        end

        it 'adds the page flow object' do
          flow = generator.to_metadata['flow']
          expect(flow.keys).to include('mandalorian-123')
          expect(flow['mandalorian-123']).to eq(expected_flow_metadata)
        end

        it 'links the previous page flow object to the new page flow object' do
          previous_page = generator.to_metadata['flow'][add_page_after]
          expect(previous_page['next']['default']).to eq('mandalorian-123')
        end

        it 'creates valid service flow metadata' do
          expect(
            MetadataPresenter::ValidateSchema.validate(
              generator.to_metadata['flow'], 'flow.base'
            )
          ).to be(valid)
        end
      end

      context 'when inserting page after an invalid page' do
        let(:add_page_after) { 'this-uuid-does-not-exist' }

        it 'adds new page in last position' do
          expect(generator.to_metadata['pages']).to_not be_blank
          expect(generator.to_metadata['pages'].last).to include(page_attributes)
        end

        it 'sends a message to Sentry' do
          expect(Sentry).to receive(:capture_message).with(
            "Unable to set default next. #{add_page_after} does not exist in service flow"
          )
          generator.to_metadata
        end
      end

      it 'generates page attributes' do
        expect(generator.to_metadata['pages']).to_not be_blank
        expect(generator.to_metadata['pages'].last).to include(page_attributes)
      end
    end

    context 'when no latest_metadata present' do
      subject(:generator) do
        described_class.new(
          page_type: 'standalone',
          page_url: page_url
        )
      end

      it 'should return just the page metadata' do
        expect(generator.to_metadata['_type']).to eq('page.standalone')
      end
    end

    context 'when adding an exit page into the middle of the flow' do
      let(:latest_metadata) { metadata_fixture(:branching_2) }
      let(:page_type) { 'exit' }
      let(:component_type) { '' }
      let(:add_page_after) { service.find_page_by_url('page-d').uuid }

      it 'saves exit page with the next default as empty' do
        expect(
          generator.to_metadata['flow']['mandalorian-123']['next']['default']
        ).to eq('')
      end
    end

    context 'when adding an page after a branch' do
      let(:latest_metadata) { metadata_fixture(:branching_2) }
      let(:add_page_after) do
        # Branching point 1
        '09e91fd9-7a46-4840-adbc-244d545cfef7'
      end
      let(:branch) do
        generator.to_metadata['flow'][add_page_after]
      end
      let(:flow) do
        MetadataPresenter::Flow.new(add_page_after, branch)
      end
      let(:updated_conditional) do
        flow.conditionals.find do |conditional|
          conditional.uuid == conditional_uuid
        end
      end

      context 'when adding an exit page' do
        let(:page_type) { 'exit' }
        let(:component_type) { '' }
        let(:conditional_uuid) { 'b753b3f0-188e-4435-a84d-894557ba2007' }

        it 'change branch condition destination to the new page' do
          expect(updated_conditional).to_not be_nil
          expect(updated_conditional.next).to eq('mandalorian-123')
        end

        it 'saves exit page with the next default as empty' do
          expect(
            generator.to_metadata['flow']['mandalorian-123']['next']['default']
          ).to eq('')
        end
      end

      context 'when adding a page to the otherwise condition' do
        # adding after a branch with no conditional leads towards the otherwise
        let(:conditional_uuid) { nil }
        let(:page_type) { 'singlequestion' }
        let(:component_type) { 'text' }

        it 'change branch otherwise destination to the new page' do
          expect(branch['next']['default']).to eq('mandalorian-123')
        end

        it 'makes new page point to what the otherwise condition was pointing at' do
          expect(
            generator.to_metadata['flow']['mandalorian-123']['next']['default']
          ).to eq(service.find_page_by_url('page-j').uuid)
        end
      end

      context 'when adding a page' do
        let(:page_type) { 'singlequestion' }
        let(:component_type) { 'text' }
        let(:conditional_uuid) { 'b753b3f0-188e-4435-a84d-894557ba2007' }

        it 'change branch condition destination to the new page' do
          expect(updated_conditional).to_not be_nil
          expect(updated_conditional.next).to eq('mandalorian-123')
        end

        it 'makes new page point to what the branching condition was pointing at' do
          expect(
            generator.to_metadata['flow']['mandalorian-123']['next']['default']
          ).to eq(service.find_page_by_url('page-c').uuid)
        end
      end
    end

    context 'when adding a flow page' do
      let(:latest_metadata) { metadata_fixture(:service) }

      it 'adds the page to the pages array' do
        expect(generator.to_metadata['pages'].count).to eq(2) # including start page
      end

      it 'adds the flow page object to service flow' do
        metadata = generator.to_metadata
        page_uuids = metadata['pages'].map { |page| page['_uuid'] }
        flow_uuids = metadata['flow'].keys

        expect(generator.to_metadata['flow'].count).to eq(2)
        expect(flow_uuids).to eq(page_uuids)
      end

      it 'updates the previous pages flow object default next to the new page uuid' do
        start_page_flow = generator.to_metadata['flow']['86ed04ac-1727-4172-8dd2-608009f1a656']
        expect(start_page_flow['next']['default']).to eq('mandalorian-123')
      end
    end

    context 'when adding a standalone page' do
      subject(:generator) do
        described_class.new(
          page_type: 'standalone',
          latest_metadata: latest_metadata,
          page_url: page_url
        )
      end
      let(:latest_metadata) { metadata_fixture(:service) }

      it 'adds the page to the standalone_pages array' do
        metadata = generator.to_metadata
        expect(metadata['standalone_pages'].count).to eq(4) # there are 3 pages generated there already by default
        expect(metadata['pages'].count).to eq(1)
        expect(metadata['flow'].count).to eq(1)
      end
    end
  end

  describe '#page_metadata' do
    let(:page_url) { 'home-one' }

    context 'when there is a / in the page _id' do
      let(:page_type) { 'standalone' }
      let(:page_url) { '/home-one/' }
      let(:latest_metadata) { nil }
      let(:component_type) { nil }

      it 'removes the / in page name' do
        expect(generator.page_metadata['_id']).to eq('page.home-one')
      end
    end

    context 'when valid metadata for start page' do
      let(:latest_metadata) { metadata_fixture(:service) }
      let(:page_type) { 'start' }
      let(:component_type) { nil }

      it 'creates a valid page metadata' do
        expect(
          MetadataPresenter::ValidateSchema.validate(
            generator.page_metadata, "page.#{page_type}"
          )
        ).to be(valid)
      end
    end

    context 'when valid metadata for all other pages' do
      let(:latest_metadata) { metadata_fixture(:version) }

      context 'generating valid metadata' do
        context 'single questions pages with input components' do
          %w[checkboxes date number radios text textarea upload email autocomplete].each do |type|
            context "when #{type} component" do
              let(:page_type) { 'singlequestion' }
              let(:component_type) { type }

              it 'creates a valid page metadata' do
                expect(
                  MetadataPresenter::ValidateSchema.validate(
                    generator.page_metadata, "page.#{page_type}"
                  )
                ).to be(valid)
              end
            end
          end
        end

        context 'pages without components when first generated' do
          %w[multiplequestions checkanswers confirmation exit].each do |page|
            context "when #{page} page" do
              let(:page_type) { page }
              let(:component_type) { nil }

              it 'creates a valid page metadata' do
                expect(
                  MetadataPresenter::ValidateSchema.validate(
                    generator.page_metadata, "page.#{page_type}"
                  )
                ).to be(valid)
              end
            end
          end
        end

        context 'pages that allow only content components' do
          %w[content checkanswers confirmation exit].each do |page|
            context "when #{page} page" do
              let(:page_type) { page }
              let(:component_type) { 'content' }

              it 'creates a valid page metadata' do
                expect(
                  MetadataPresenter::ValidateSchema.validate(
                    generator.page_metadata, "page.#{page_type}"
                  )
                ).to be(valid)
              end
            end
          end
        end

        context 'multiple questions page allow any component type' do
          %w[checkboxes content date number radios text textarea email].each do |type|
            context "when #{type} component type" do
              let(:page_type) { 'multiplequestions' }
              let(:component_type) { type }

              it 'creates a valid page metadata' do
                expect(
                  MetadataPresenter::ValidateSchema.validate(
                    generator.page_metadata, "page.#{page_type}"
                  )
                ).to be(valid)
              end
            end
          end
        end

        context 'standalone page type' do
          let(:page_type) { 'standalone' }
          let(:component_type) { nil }

          it 'creates a valid page metadata' do
            expect(
              MetadataPresenter::ValidateSchema.validate(
                generator.page_metadata, "page.#{page_type}"
              )
            ).to be(valid)
          end
        end
      end

      context 'when metadata is invalid' do
        context 'pages that only allow content components' do
          %w[content checkanswers confirmation exit].each do |page|
            %w[checkboxes date number radios text textarea email].each do |type|
              context "#{page} page and #{type} component" do
                let(:page_type) { page }
                let(:component_type) { type }

                it 'raises a validation error' do
                  expect {
                    MetadataPresenter::ValidateSchema.validate(
                      generator.page_metadata, "page.#{page_type}"
                    )
                  }.to raise_error(JSON::Schema::ValidationError)
                end
              end
            end
          end
        end
      end
    end
  end
end
