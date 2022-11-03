RSpec.describe AutocompleteItemsPresenter do
  subject(:autocomplete_items_presenter) { described_class.new(service, autocomplete_items) }
  let(:page) { service.find_page_by_url('countries') }
  let(:component_uuid) { page.components.first.uuid }
  let(:component_title) { page.components.first.humanised_title }
  let(:page_uuid) { page.uuid }
  let(:environment) { 'test' }
  let(:warning_messages) { [I18n.t("publish.autocomplete_items.#{environment}.message")] }

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
        expect(autocomplete_items_presenter.messages).to eq(warning_messages)
      end
    end

    context 'when there are no items for a service' do
      let(:autocomplete_items) { double(metadata: { 'items' => {} }) }

      it 'it should return an array with warning messages' do
        expect(autocomplete_items_presenter.messages).to eq(warning_messages)
      end
    end
  end
end
