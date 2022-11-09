RSpec.describe AutocompleteItemsPresenter do
  subject(:autocomplete_items_presenter) { described_class.new(service, autocomplete_items, environment) }
  let(:page) { service.find_page_by_url('countries') }
  let(:component_uuid) { page.components.first.uuid }
  let(:component_title) { page.components.first.humanised_title }
  let(:page_uuid) { page.uuid }
  let(:environment) { 'dev' }
  let(:warning_messages) { I18n.t("publish.autocomplete_items.#{environment}.message", title: component_title) }
  let(:url) { "/services/#{service.service_id}/pages/#{page_uuid}/edit" }

  describe '#messages' do
    context 'when all components have items' do
      let(:autocomplete_items) do
        double(metadata: {
          'items' => { component_uuid => { 'text': '123', 'value': 'abc' } }
        })
      end

      it 'should return empty' do
        expect(autocomplete_items_presenter.messages).to be_empty
      end
    end

    context 'when a component does not have items' do
      let(:autocomplete_items) do
        double(metadata: {
          'items' => { SecureRandom.uuid => { 'text': '123', 'value': 'abc' } }
        })
      end

      it 'should return an array with warning messages' do
        expect(strip_tags(autocomplete_items_presenter.messages.first)).to eq(warning_messages)
      end

      it 'should link to the correct page of the service' do
        expect(autocomplete_items_presenter.messages.first).to include(url)
      end
    end

    context 'when there are no items for a service' do
      let(:autocomplete_items) { double(metadata: { 'items' => {} }) }

      it 'it should return an array with warning messages' do
        expect(strip_tags(autocomplete_items_presenter.messages.first)).to eq(warning_messages)
      end
    end

    def strip_tags(string)
      ActionController::Base.helpers.strip_tags(string)
    end
  end
end
