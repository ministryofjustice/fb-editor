RSpec.describe PagesController do
  describe '#page_update_params' do
    let(:page) { service.find_page_by_url('/name') }
    before do
      controller.instance_variable_set(:@page, page)
      allow(controller).to receive(:params).and_return(
        ActionController::Parameters.new(page: params)
      )
      allow(controller).to receive(:service_metadata).and_return(service_metadata)
    end

    context 'when components are present' do
      let(:component_params_one) do
        {
          'items' => [
            { 'value' => 'Yes' },
            { 'value' => 'No' }
          ]
        }
      end
      let(:component_params_two) do
        {
          'items' => [
            { 'value' => 'Star Wars' },
            { 'value' => 'Star Trek' }
          ]
        }
      end
      let(:params) do
        {
          components: {
            '0' => JSON.dump(component_params_one),
            '1' => JSON.dump(component_params_two)
          }
        }
      end

      it 'parses components as json' do
        expect(controller.page_update_params).to eq({
          'id' => page.id,
          'latest_metadata' => service_metadata,
          'components' => [component_params_one, component_params_two],
          'service_id' => service.service_id
        })
      end
    end

    context 'when components are not present' do
      let(:params) { { heading: 'They are taking the Hobbits to Isengard' } }

      it 'parses params' do
        expect(controller.page_update_params).to eq({
          'id' => page.id,
          'latest_metadata' => service_metadata,
          'service_id' => service.service_id,
          'heading' => 'They are taking the Hobbits to Isengard'
        })
      end
    end

    context 'when adding a new component' do
      context 'when adding a component' do
        let(:params) do
          { add_component: 'radios' }
        end

        it 'returns actions to add a component' do
          expect(controller.page_update_params).to include(
            'actions' => {
              'add_component' => 'radios',
              'component_collection' => 'components'
            }
          )
        end
      end

      context 'when adding an extra component' do
        let(:params) do
          { add_extra_component: 'radios', component_collection: 'extra_components' }
        end

        it 'returns actions to add a component' do
          expect(controller.page_update_params).to include(
            'actions' => {
              'add_component' => 'radios',
              'component_collection' => 'extra_components'
            }
          )
        end
      end
    end
  end
end
