require 'rails_helper'

RSpec.describe '', type: :request do
  describe 'GET /api/services/:service_id/pages/:page_uuid' do
    let(:request) do
      get "/api/services/#{service_id}/pages/#{page.uuid}"
    end
    let(:service_obj) { service }
    let(:service_id) { service_obj.service_id }
    let(:page) { service.find_page_by_url('name') }
    let(:expected_response) do
      {
        meta: {
          default_text: {
            section_heading: '[Optional section heading]',
            lede: '[Optional lede paragraph]',
            body: '[Optional content]',
            content: '[Optional content]',
            hint: '[Optional hint text]',
            option: 'Option',
            option_hint: '[Optional hint text]'
          }
        }
      }
    end

    context 'when authenticated' do
      before do
        allow_any_instance_of(
          Api::PagesController
        ).to receive(:require_user!).and_return(true)

        request
      end

      it 'shows the default text' do
        expect(
          JSON.parse(response.body)
        ).to include(expected_response.deep_stringify_keys)
      end
    end

    context 'when not authenticated' do
      before do
        allow_any_instance_of(
          Api::PagesController
        ).to receive(:current_user).and_return(nil)

        request
      end

      it 'returns 401 unauthorised' do
        expect(response.status).to be(401)
      end
    end
  end
end
