RSpec.describe 'Expressions spec', type: :request do
  describe 'GET /api/services/:service_id/components/:component_id/conditionals/:conditionals_index/expressions/:expressions_index' do
    let(:request) do
      get "/api/services/#{service.service_id}/components/#{component_id}/conditionals/#{conditionals_index}/expressions/#{expressions_index}"
    end

    context 'when authenticated' do
      let(:page) { service.find_page_by_url('do-you-like-star-wars') }
      let(:component_id) { page.components.first.uuid }
      let(:conditionals_index) { 0 }
      let(:expressions_index) { 1 }
      let(:expected_operators) do
        [
          '<option data-hide-answers="false" value="is">is</option>',
          '<option data-hide-answers="false" value="is_not">is not</option>',
          '<option data-hide-answers="true" value="is_answered">is answered</option>',
          '<option data-hide-answers="true" value="is_not_answered">is not answered</option>'
        ]
      end
      let(:expected_answers) do
        [
          '<option value="c5571937-9388-4411-b5fa-34ddf9bc4ca0">Only on weekends</option>',
          '<option value="67160ff1-6f7c-43a8-8bf6-49b3d5f450f6">Hell no!</option></select>'
        ]
      end
      let(:expected_conditional_index) do
        'branch[conditionals_attributes][0]'
      end

      before do
        allow_any_instance_of(
          Api::ExpressionsController
        ).to receive(:require_user!).and_return(true)

        allow_any_instance_of(
          Api::ExpressionsController
        ).to receive(:service).and_return(service)

        request
      end

      it 'returns all the operators' do
        expected_operators.each do |operator|
          expect(response.body).to include(operator)
        end
      end

      it 'returns all the answers' do
        expected_answers.each do |answer|
          expect(response.body).to include(answer)
        end
      end

      it 'returns the correct conditional index' do
        expect(response.body).to include(expected_conditional_index)
      end

      context 'when the api request is incorrect' do
        let(:conditionals_index) { 'hello' }
        it 'returns a 422 unprocessable entity error' do
          expect(response.status).to be(422)
        end
      end
    end
  end
end
