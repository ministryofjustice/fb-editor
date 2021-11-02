RSpec.describe Uptime::Adapters::Pingdom do
  subject(:pingdom) do
    described_class.new(root_url: pingdom_api)
  end
  let(:pingdom_api) { 'https://pingdom-api.com' }
  let(:service_name) { 'My awesome service' }
  let(:host) { 'my-awesome-service' }
  let(:alert_integration_id) { '1234' }
  let(:expected_payload) do
    {
      name: "Form Builder - #{service_name}",
      host: host,
      type: 'http',
      encryption: true,
      integrationids: [alert_integration_id],
      port: 443,
      probe_filters: ['region:EU'],
      resolution: 1,
      sendnotificationwhendown: 6,
      tags: [service_name],
      url: '/health'
    }
  end
  let(:checks) { Uptime::Adapters::Pingdom::CHECKS }
  let(:pingdom_stub) do
    stub_request(action, pingdom_api_url)
      .with(
        body: expected_payload.to_json,
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type' => 'application/json',
          'User-Agent' => 'Faraday v1.8.0'
        }
      )
  end
  let(:check_id) { '9876' }

  before do
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with('PINGDOM_TOKEN').and_return(SecureRandom.uuid)
    allow(ENV).to receive(:[]).with('PINGDOM_ALERT_INTEGRATION_ID').and_return(alert_integration_id)
    pingdom_stub
  end

  # might remove
  describe '#check' do
  end

  describe '#create' do
    let(:action) { :post }
    let(:pingdom_api_url) { "#{pingdom_api}/#{checks}" }

    it 'sends the correct payload when creating a pingdom check' do
      expect_any_instance_of(Faraday::Connection).to receive(
        :post
      ).with(checks, expected_payload)
      pingdom.create(service_name, host)
    end
  end

  describe '#update' do
    let(:action) { :put }
    let(:pingdom_api_url) { "#{pingdom_api}/#{checks}/#{check_id}" }

    it 'sends the correct payload when creating a pingdom check' do
      expect_any_instance_of(Faraday::Connection).to receive(
        :put
      ).with("#{checks}/#{check_id}", expected_payload)
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
