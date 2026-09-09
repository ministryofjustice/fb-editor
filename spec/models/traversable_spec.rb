RSpec.describe Traversable do
  subject(:traversable) do
    described_class.new(service:, flow_uuid:)
  end

  def traversable_urls
    traversable.question_pages.map(&:url)
  end

  describe '#question_pages' do
    context 'simple flow with no branching' do
      let(:metadata) { metadata_fixture(:version) }
      let(:service) { MetadataPresenter::Service.new(metadata) }

      context 'adding a branch at the end of the flow' do
        let(:flow_uuid) { service.pages[-3].uuid } # page before check answers
        let(:expected_urls) do
          %w[
            name
            email-address
            parent-name
            your-age
            family-hobbies
            do-you-like-star-wars
            holiday
            burgers
            star-wars-knowledge
            dog-picture
            dog-picture-2
            countries
            postal-address
          ]
        end

        it 'returns only traversable question pages' do
          expect(traversable_urls).to eq(expected_urls)
        end
      end

      context 'adding a branch in the middle of the flow' do
        let(:flow_uuid) { service.pages[3].uuid }
        let(:expected_urls) { %w[name email-address parent-name] }

        it 'returns only traversable question pages' do
          expect(traversable_urls).to eq(expected_urls)
        end
      end

      context 'adding a branch when there are no previous question pages' do
        let(:flow_uuid) { service.start_page.uuid }

        it 'does not return any question pages' do
          expect(traversable_urls).to be_empty
        end
      end
    end

    context 'simple branching flow' do
      let(:metadata) { metadata_fixture(:branching) }
      let(:service) { MetadataPresenter::Service.new(metadata) }

      context 'adding a branch at the end of the flow' do
        let(:flow_uuid) { service.pages[-3].uuid } # page before check answers
        let(:expected_urls) do
          %w[name
             do-you-like-star-wars
             star-wars-knowledge
             favourite-fruit
             apple-juice
             orange-juice
             favourite-band
             music-app
             best-formbuilder
             which-formbuilder
             burgers
             marvel-series
             best-arnold-quote]
        end

        it 'returns only traversable question pages' do
          expect(traversable_urls).to eq(expected_urls)
        end
      end

      context 'adding a branch in the middle of the flow' do
        let(:flow_uuid) { service.pages[8].uuid } # music-app (currently)
        let(:expected_urls) do
          %w[name
             do-you-like-star-wars
             star-wars-knowledge
             favourite-fruit
             apple-juice
             orange-juice
             favourite-band
             music-app]
        end

        it 'returns only traversable question pages' do
          expect(traversable_urls).to eq(expected_urls)
        end
      end
    end
  end
end
