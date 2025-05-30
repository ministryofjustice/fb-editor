require 'rails_helper'
require 'webmock/rspec'

RSpec.describe MicrosoftGraphAdapter do
  subject(:graph_service) { described_class.new(site_id: 'site_id', service:, env: 'dev') }

  let(:latest_metadata) { metadata_fixture(:branching) }
  let(:service) { MetadataPresenter::Service.new(latest_metadata) }
  let(:drive_name) { "#{service.service_name}-attachments" }

  context 'when creating a drive for this submission' do
    context 'when successful' do
      before do
        stub_request(:post, 'https://graph.microsoft.com/v1.0//sites/site_id/drive/items/root/children')
        .with(
          body: '{"name":"Branching Fixture-attachments","folder":{}}',
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => 'Bearer valid_token',
            'Content-Type' => 'application/json',
            'User-Agent' => "Faraday v#{Faraday::VERSION}"
          }
        )
        .to_return(status: 201, body: { 'id' => 'a-drive-id' }.to_json, headers: {})

        stub_request(:post, 'https://authurl.example.com')
          .to_return(status: 200, body: { 'access_token' => 'valid_token' }.to_json, headers: {})

        allow(ENV).to receive(:[])

        allow(ENV).to receive(:[]).with('MS_OAUTH_URL').and_return('https://authurl.example.com')
      end

      it 'returns the drive id' do
        expect(JSON.parse(graph_service.create_drive(drive_name).body)['id']).to eq('a-drive-id')
      end
    end

    context 'when api responds with error' do
      before do
        stub_request(:post, 'https://graph.microsoft.com/v1.0//sites/site_id/drive/items/root/children')
        .with(
          body: '{"name":"Branching Fixture-attachments","folder":{}}',
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => 'Bearer valid_token',
            'Content-Type' => 'application/json',
            'User-Agent' => "Faraday v#{Faraday::VERSION}"
          }
        ).to_return(status: 500, body: {}.to_json, headers: {})

        stub_request(:post, 'https://authurl.example.com')
          .to_return(status: 200, body: { 'access_token' => 'valid_token' }.to_json, headers: {})

        allow(ENV).to receive(:[])

        allow(ENV).to receive(:[]).with('MS_OAUTH_URL').and_return('https://authurl.example.com')
      end

      it 'sends error up the chain' do
        expect(graph_service.create_drive(drive_name).status).to eq(500)
      end
    end
  end

  context 'when authenticating' do
    context 'when successful' do
      before do
        stub_request(:post, 'https://graph-url.microsoft.com/sites/1234/drive/items/root/children')
        .to_return(status: 500, body: {}.to_json, headers: {})

        stub_request(:post, 'https://authurl.example.com')
          .with(
            body: { 'client_id' => 'app_id', 'client_secret' => 'app_secret', 'grant_type' => 'client_credentials', 'resource' => 'https://graph.microsoft.com/' },
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Content-Type' => 'application/x-www-form-urlencoded',
              'User-Agent' => "Faraday v#{Faraday::VERSION}"
            }
          ).to_return(status: 200, body: { 'access_token' => 'valid_token' }.to_json, headers: {})

        allow(ENV).to receive(:[])

        allow(ENV).to receive(:[]).with('MS_OAUTH_URL').and_return('https://authurl.example.com')
        allow(ENV).to receive(:[]).with('MS_ADMIN_APP_ID').and_return('app_id')
        allow(ENV).to receive(:[]).with('MS_ADMIN_APP_SECRET').and_return('app_secret')
      end

      it 'calls the api with the form and return the value' do
        expect(graph_service.get_auth_token).to eq('valid_token')
      end
    end

    context 'when api responds with error' do
      before do
        stub_request(:post, 'https://graph-url.microsoft.com/sites/1234/drive/items/root/children')
        .to_return(status: 500, body: {}.to_json, headers: {})

        stub_request(:post, 'https://authurl.example.com')
          .with(
            body: { 'client_id' => 'app_id', 'client_secret' => 'app_secret', 'grant_type' => 'client_credentials', 'resource' => 'https://graph.microsoft.com/' },
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Content-Type' => 'application/x-www-form-urlencoded',
              'User-Agent' => "Faraday v#{Faraday::VERSION}"
            }
          ).to_return(status: 500, body: {}.to_json, headers: {})

        allow(ENV).to receive(:[])

        allow(ENV).to receive(:[]).with('MS_OAUTH_URL').and_return('https://authurl.example.com')
        allow(ENV).to receive(:[]).with('MS_ADMIN_APP_ID').and_return('app_id')
        allow(ENV).to receive(:[]).with('MS_ADMIN_APP_SECRET').and_return('app_secret')
      end

      it 'calls the api with the form and return the value' do
        expect { graph_service.get_auth_token }.to raise_error(Faraday::ServerError)
      end
    end

    context 'when permission denied' do
      before do
        stub_request(:post, 'https://graph-url.microsoft.com/sites/1234/drive/items/root/children')
        .to_return(status: 500, body: {}.to_json, headers: {})

        stub_request(:post, 'https://authurl.example.com')
          .with(
            body: { 'client_id' => 'app_id', 'client_secret' => 'app_secret', 'grant_type' => 'client_credentials', 'resource' => 'https://graph.microsoft.com/' },
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Content-Type' => 'application/x-www-form-urlencoded',
              'User-Agent' => "Faraday v#{Faraday::VERSION}"
            }
          ).to_return(status: 403, body: {}.to_json, headers: {})

        allow(ENV).to receive(:[])

        allow(ENV).to receive(:[]).with('MS_OAUTH_URL').and_return('https://authurl.example.com')
        allow(ENV).to receive(:[]).with('MS_ADMIN_APP_ID').and_return('app_id')
        allow(ENV).to receive(:[]).with('MS_ADMIN_APP_SECRET').and_return('app_secret')
      end

      it 'calls the api with the form and return the value' do
        expect { graph_service.get_auth_token }.to raise_error(Faraday::ForbiddenError)
      end
    end
  end

  context 'when creating list' do
    context 'when successful' do
      let(:response) do
        {
          'list_updated' => 'today'
        }
      end

      before do
        stub_request(:post, 'https://graph.microsoft.com/v1.0//sites/site_id/lists/')
        .with(
          body: "{\"displayName\":\"Branching Fixture - test - 27dc30c9-f7b8-4dec-973a-bd153f6797df\",\"columns\":[{\"name\":\"debcefbcbdf\",\"displayName\":\"Submission ID\",\"text\":{}},{\"name\":\"bdfaeebcbe\",\"displayName\":\"Reference Number\",\"text\":{}},{\"name\":\"bfebbbeafabacdef\",\"displayName\":\"Full name from name\",\"text\":{\"allowMultipleLines\":true,\"appendChangesToExistingText\":false,\"linesForEditing\":6,\"maxLength\":10000,\"textType\":\"richText\"}},{\"name\":\"deaffeabbcdf\",\"displayName\":\"Do you like Star Wars? from do-you-like-star-wars\",\"text\":{\"allowMultipleLines\":true,\"appendChangesToExistingText\":false,\"linesForEditing\":6,\"maxLength\":10000,\"textType\":\"richText\"}},{\"name\":\"adcbfeffadfdf\",\"displayName\":\"What was the name of the band playing in Jabba's palace? from star-wars-knowledge\",\"text\":{\"allowMultipleLines\":true,\"appendChangesToExistingText\":false,\"linesForEditing\":6,\"maxLength\":10000,\"textType\":\"richText\"}},{\"name\":\"fffcaaefdfffb\",\"displayName\":\"What is The Mandalorian's real name? from star-wars-knowledge\",\"text\":{\"allowMultipleLines\":true,\"appendChangesToExistingText\":false,\"linesForEditing\":6,\"maxLength\":10000,\"textType\":\"richText\"}},{\"name\":\"fcbdbbfeb\",\"displayName\":\"What is your favourite fruit? from favourite-fruit\",\"text\":{\"allowMultipleLines\":true,\"appendChangesToExistingText\":false,\"linesForEditing\":6,\"maxLength\":10000,\"textType\":\"richText\"}},{\"name\":\"fbaebbacfbcf\",\"displayName\":\"Do you like apple juice? from apple-juice\",\"text\":{\"allowMultipleLines\":true,\"appendChangesToExistingText\":false,\"linesForEditing\":6,\"maxLength\":10000,\"textType\":\"richText\"}},{\"name\":\"cceafbaeaafd\",\"displayName\":\"Do you like orange juice? from orange-juice\",\"text\":{\"allowMultipleLines\":true,\"appendChangesToExistingText\":false,\"linesForEditing\":6,\"maxLength\":10000,\"textType\":\"richText\"}},{\"name\":\"dfafceedaf\",\"displayName\":\"What is your favourite band? from favourite-band\",\"text\":{\"allowMultipleLines\":true,\"appendChangesToExistingText\":false,\"linesForEditing\":6,\"maxLength\":10000,\"textType\":\"richText\"}},{\"name\":\"fdfdadedafbfde\",\"displayName\":\"Which app do you use to listen music? from music-app\",\"text\":{\"allowMultipleLines\":true,\"appendChangesToExistingText\":false,\"linesForEditing\":6,\"maxLength\":10000,\"textType\":\"richText\"}},{\"name\":\"ddebbfcfcbcdf\",\"displayName\":\"What is the best form builder? from best-formbuilder\",\"text\":{\"allowMultipleLines\":true,\"appendChangesToExistingText\":false,\"linesForEditing\":6,\"maxLength\":10000,\"textType\":\"richText\"}},{\"name\":\"baaafbafaecbbaff\",\"displayName\":\"Which Formbuilder is the best? from which-formbuilder\",\"text\":{\"allowMultipleLines\":true,\"appendChangesToExistingText\":false,\"linesForEditing\":6,\"maxLength\":10000,\"textType\":\"richText\"}},{\"name\":\"eafdebfefacf\",\"displayName\":\"What would you like on your burger? from burgers\",\"text\":{\"allowMultipleLines\":true,\"appendChangesToExistingText\":false,\"linesForEditing\":6,\"maxLength\":10000,\"textType\":\"richText\"}},{\"name\":\"ddcecdbadb\",\"displayName\":\"What is the best marvel series? from marvel-series\",\"text\":{\"allowMultipleLines\":true,\"appendChangesToExistingText\":false,\"linesForEditing\":6,\"maxLength\":10000,\"textType\":\"richText\"}},{\"name\":\"cceadacfdc\",\"displayName\":\"Select all Arnold Schwarzenegger quotes from best-arnold-quote\",\"text\":{\"allowMultipleLines\":true,\"appendChangesToExistingText\":false,\"linesForEditing\":6,\"maxLength\":10000,\"textType\":\"richText\"}}],\"list\":{\"template\":null}}",
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => 'Bearer valid_token',
            'Content-Type' => 'application/json',
            'User-Agent' => "Faraday v#{Faraday::VERSION}"
          }
        ).to_return(status: 200, body: response.to_json, headers: {})

        stub_request(:post, 'https://authurl.example.com')
          .to_return(status: 200, body: { 'access_token' => 'valid_token' }.to_json, headers: {})

        allow(ENV).to receive(:[])

        allow(ENV).to receive(:[]).with('MS_OAUTH_URL').and_return('https://authurl.example.com')
      end

      it 'returns returns the api response' do
        expect(JSON.parse(graph_service.post_list_columns.body)).to eq(response)
      end
    end
  end
end
