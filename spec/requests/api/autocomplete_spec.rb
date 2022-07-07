require 'rails_helper'

RSpec.describe 'Autocomplete spec', type: :request do
  before do
    allow_any_instance_of(
      Api::AutocompleteController
    ).to receive(:require_user!).and_return(true)

    allow_any_instance_of(
      Api::AutocompleteController
    ).to receive(:service).and_return(service)
  end

  describe 'GET /api/services/:service_id/components/:component_id/autocomplete' do
    let(:request) do
      get "/api/services/#{service_id}/components/#{component_id}/autocomplete"
    end
    let(:service_id) { SecureRandom.uuid }
    let(:component_id) { SecureRandom.uuid }

    context 'when authenticated' do
      it 'returns a 200' do
        request
        expect(response.status).to eq(200)
      end
    end
  end

  describe 'POST /api/services/:service_id/components/:component_id/autocomplete' do
    let(:request) do
      post "/api/services/#{service_id}/components/#{component_id}/autocomplete", params: params
    end
    let(:service_id) { SecureRandom.uuid }
    let(:component_id) { SecureRandom.uuid }
    let(:path_to_file) { Rails.root.join('spec', 'fixtures', 'valid.csv') }
    let(:file) { Rack::Test::UploadedFile.new path_to_file, 'text/csv' }
    let(:params) { { autocomplete_items: { file: file } } }

    context 'when there is a file uploaded' do
      context 'and the file is a valid csv' do
        context 'the metadata api accepts the request' do
          let(:api_response) { double(errors?: false) }
          before do
            allow(MetadataApiClient::Items).to receive(:create).and_return(api_response)
          end

          it 'returns a 201' do
            request
            expect(response.status).to eq(201)
          end
        end

        context 'the metadata api rejects the request' do
          let(:api_response) { MetadataApiClient::ErrorMessages.new(['error message']) }

          before do
            allow(MetadataApiClient::Items).to receive(:create).and_return(api_response)
          end

          it 'returns a 422' do
            request
            expect(response.status).to eq(422)
          end
        end
      end

      context 'the file is invalid' do
        context 'the file is not a csv' do
          let(:path_to_file) { Rails.root.join('spec', 'fixtures', 'computer_says_no.gif') }
          let(:file) { Rack::Test::UploadedFile.new path_to_file, 'image/gif' }

          it 'returns a 422' do
            request
            expect(response.status).to eq(422)
          end
        end

        context 'the file does not have headings' do
          let(:path_to_file) { Rails.root.join('spec', 'fixtures', 'invalid.csv') }
          it 'returns a 422' do
            request
            expect(response.status).to eq(422)
          end
        end
      end
    end

    context 'when there is no file uploaded' do
      let(:params) { { autocomplete_items: nil } }

      it 'returns a 422' do
        request
        expect(response.status).to eq(422)
      end
    end
  end
end
