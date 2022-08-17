require 'rails_helper'

RSpec.describe 'Autocomplete spec', type: :request do
  before do
    allow_any_instance_of(
      Api::AutocompleteController
    ).to receive(:require_user!).and_return(true)

    allow_any_instance_of(
      Api::AutocompleteController
    ).to receive(:service).and_return(service)

    allow(MalwareScanner).to receive(:call).and_return(false)
  end

  describe 'GET /api/services/:service_id/components/:component_id/autocomplete' do
    let(:request) do
      get "/api/services/#{service_id}/components/#{component_id}/autocomplete"
    end
    let(:service_id) { SecureRandom.uuid }
    let(:component_id) { SecureRandom.uuid }

    context 'when there are items for a component' do
      before do
        allow(MetadataApiClient::Items).to receive(:find).and_return(api_response)

        request
      end

      let(:api_response) do
        MetadataApiClient::Items.new(
          { 'items' => { '123456789' => [{ 'text' => 'value' }] } }
        )
      end

      it 'returns a 200' do
        expect(response.status).to eq(200)
      end

      it 'has the warning message for existing items' do
        expect(response.body).to include(I18n.t('dialogs.autocomplete.modal_warning'))
      end
    end

    context 'when the component does not have existing items' do
      before do
        allow(MetadataApiClient::Items).to receive(:find).and_return(double(errors?: true))

        request
      end

      it 'should not show the warning message' do
        expect(response.body).to_not include(I18n.t('dialogs.autocomplete.modal_warning'))
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
      before do
        allow_any_instance_of(ApplicationHelper).to receive(:items_present?)
        .with(component_id)
        .and_return(true)
      end

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

      before do
        allow_any_instance_of(ApplicationHelper).to receive(:items_present?)
        .with(component_id)
        .and_return(true)
      end

      it 'returns a 422' do
        request
        expect(response.status).to eq(422)
      end
    end
  end
end
