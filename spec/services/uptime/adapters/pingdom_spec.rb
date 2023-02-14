RSpec.describe Uptime::Adapters::Pingdom do
  subject(:pingdom) do
    described_class.new(root_url: pingdom_api)
  end
  let(:pingdom_api) { 'https://pingdom-api.com' }
  let(:service_name) { 'My awesome service' }
  let(:service_id) { 'some-service-id' }
  let(:host) { 'my-awesome-service' }
  let(:alert_integration_id) { '1234' }
  let(:expected_payload) do
    {
      name: "Form Builder - #{service_name}",
      host:,
      type: 'http',
      encryption: true,
      integrationids: [alert_integration_id],
      port: 443,
      probe_filters: ['region:EU'],
      resolution: 1,
      sendnotificationwhendown: 6,
      tags: [service_id],
      url: '/health'
    }
  end
  let(:checks) { Uptime::Adapters::Pingdom::CHECKS }
  let(:response_body) do
    {
      status: 200,
      body: expected_body.to_json,
      headers: {}
    }
  end
  let(:expected_body) do
    {
      'check' => {
        'id' => check_id
      }
    }
  end
  let(:pingdom_stub) do
    stub_request(action, pingdom_api_url)
      .with(
        body: expected_payload.to_json,
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type' => 'application/json',
          'User-Agent' => "Faraday v#{Faraday::VERSION}"
        }
      ).to_return(response_body)
  end
  let(:pingdom_token) { SecureRandom.uuid }
  let(:check_id) { '9876' }

  before do
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with('PINGDOM_TOKEN').and_return(pingdom_token)
    allow(ENV).to receive(:[]).with('PINGDOM_ALERT_INTEGRATION_ID').and_return(alert_integration_id)
  end

  describe '#create' do
    let(:pingdom_api_url) { "#{pingdom_api}/#{checks}" }

    context 'when creation response is 200' do
      let(:action) { :post }

      before do
        pingdom_stub
      end

      it 'sends the correct payload when creating a pingdom check' do
        response_check_id = pingdom.create(service_name, host, service_id)
        expect(response_check_id).to eq(check_id)
      end
    end

    context 'when creation response is 400' do
      let(:pingdom_api_url) { "#{pingdom_api}/#{checks}?include_tags=true" }
      let(:response_body) do
        {
          status: 200,
          body: expected_body.to_json,
          headers: {}
        }
      end
      let(:expected_body) do
        {
          'checks' => [
            {
              'id' => check_id,
              'name' => 'Form Builder - amazing form',
              'tags' => [{ 'name' => service_id }]
            },
            {
              'id' => 'some-other',
              'name' => 'some other less amazing service',
              'tags' => [{ 'name' => 'we do not need this one' }]
            }
          ]
        }
      end
      let(:action) { :get }
      let(:pingdom_stub) do
        stub_request(action, pingdom_api_url)
          .with(
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'User-Agent' => "Faraday v#{Faraday::VERSION}",
              'Authorization' => "Bearer #{pingdom_token}"
            }
          ).to_return(response_body)
      end

      before do
        stub_request(:post, "#{pingdom_api}/#{checks}")
          .with(
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'User-Agent' => "Faraday v#{Faraday::VERSION}",
              'Authorization' => "Bearer #{pingdom_token}"
            }
          ).to_return(
            {
              status: 400,
              body: '',
              headers: {}
            }
          )
        pingdom_stub
      end

      it 'returns the check id after finding it in all the checks' do
        response_check_id = pingdom.create(service_name, host, service_id)
        expect(response_check_id).to eq(check_id)
      end
    end
  end

  describe '#update' do
    let(:action) { :put }
    let(:pingdom_api_url) { "#{pingdom_api}/#{checks}/#{check_id}" }
    let(:expected_payload) do
      {
        name: "Form Builder - #{service_name}",
        host:
      }
    end

    before { pingdom_stub }

    it 'sends the correct payload when creating a pingdom check' do
      pingdom.update(check_id, service_name, host)
    end
  end

  describe '#destroy' do
    let(:action) { :destroy }
    let(:pingdom_api_url) { "#{pingdom_api}/#{checks}/#{check_id}" }

    it 'sends the correct payload when creating a pingdom check' do
      expect_any_instance_of(Faraday::Connection).to receive(
        :delete
      ).with("#{checks}/#{check_id}")
      pingdom.destroy(check_id)
    end
  end
end
