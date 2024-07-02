require 'rails_helper'
require 'webmock/rspec'

RSpec.describe MicrosoftGraphAdapter do
  subject(:graph_service) { described_class.new(site_id: 'site_id', service:) }

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
            'User-Agent' => 'Faraday v1.10.3'
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
            'User-Agent' => 'Faraday v1.10.3'
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
              'User-Agent' => 'Faraday v1.10.3'
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
              'User-Agent' => 'Faraday v1.10.3'
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
              'User-Agent' => 'Faraday v1.10.3'
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
            body: "{\"displayName\":\"Branching Fixture - test - 27dc30c9-f7b8-4dec-973a-bd153f6797df\",\"columns\":[{\"name\":\"bfebbbeafabacdef\",\"displayName\":\"Full name\",\"text\":{}},{\"name\":\"deaffeabbcdf\",\"displayName\":\"Do you like Star Wars?\",\"text\":{}},{\"name\":\"adcbfeffadfdf\",\"displayName\":\"What was the name of the band playing in Jabba's palace?\",\"text\":{}},{\"name\":\"fffcaaefdfffb\",\"displayName\":\"What is The Mandalorian's real name?\",\"text\":{}},{\"name\":\"fcbdbbfeb\",\"displayName\":\"What is your favourite fruit?\",\"text\":{}},{\"name\":\"fbaebbacfbcf\",\"displayName\":\"Do you like apple juice?\",\"text\":{}},{\"name\":\"cceafbaeaafd\",\"displayName\":\"Do you like orange juice?\",\"text\":{}},{\"name\":\"dfafceedaf\",\"displayName\":\"What is your favourite band?\",\"text\":{}},{\"name\":\"fdfdadedafbfde\",\"displayName\":\"Which app do you use to listen music?\",\"text\":{}},{\"name\":\"ddebbfcfcbcdf\",\"displayName\":\"What is the best form builder?\",\"text\":{}},{\"name\":\"baaafbafaecbbaff\",\"displayName\":\"Which Formbuilder is the best?\",\"text\":{}},{\"name\":\"eafdebfefacf\",\"displayName\":\"What would you like on your burger?\",\"text\":{}},{\"name\":\"ddcecdbadb\",\"displayName\":\"What is the best marvel series?\",\"text\":{}},{\"name\":\"cceadacfdc\",\"displayName\":\"Select all Arnold Schwarzenegger quotes\",\"text\":{}}],\"list\":{\"template\":\"genericList\"}}",
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization' => 'Bearer valid_token',
              'Content-Type' => 'application/json',
              'User-Agent' => 'Faraday v1.10.3'
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
