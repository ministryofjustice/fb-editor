RSpec.describe MetadataApiClient::Version do
  let(:metadata_api_url) { 'http://metadata-api' }
  before do
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with('METADATA_API_URL').and_return(metadata_api_url)
  end
  let(:service_id) { SecureRandom.uuid }

  describe '.create' do
    let(:expected_url) { "#{metadata_api_url}/services/#{service_id}/versions" }

    context 'when is created' do
      let(:expected_body) do
        { service_name: 'Asohka Tano', service_id: }
      end

      before do
        stub_request(:post, expected_url)
          .to_return(status: 201, body: expected_body.to_json, headers: {})
      end

      it 'returns a version' do
        expect(
          described_class.create(
            service_id:, payload: expected_body
          )
        ).to eq(described_class.new(expected_body.stringify_keys))
      end
    end

    context 'when is unprocessable entity' do
      let(:expected_body) do
        { 'message': ['Name has already been taken'] }
      end

      before do
        stub_request(:post, expected_url)
          .to_return(status: 422, body: expected_body.to_json, headers: {})
      end

      it 'assigns an error message' do
        expect(
          described_class.create(service_id:, payload: {})
        ).to eq(
          MetadataApiClient::ErrorMessages.new(['Name has already been taken'])
        )
      end

      it 'returns errors' do
        expect(
          described_class.create(service_id:, payload: {}).errors?
        ).to be_truthy
      end
    end
  end

  describe '.all' do
    let(:expected_url) { "#{metadata_api_url}/services/#{service_id}/versions" }
    let(:version_attributes) do
      {
        version_id: 'some-id',
        created_at: '10:00am'
      }
    end
    let(:version) do
      MetadataApiClient::Version.new(version_attributes.stringify_keys)
    end
    let(:expected_body) do
      {
        service_name: 'Asohka Tano',
        service_id:,
        versions: [version]
      }
    end
    let(:expected_result) { [version] }

    before do
      stub_request(:get, expected_url)
        .to_return(status: 200, body: expected_body.to_json, headers: {})
    end

    it 'returns all the versions for a service' do
      expect(described_class.all(service_id)).to eq(expected_result)
    end
  end

  describe '.find' do
    let(:version_id) { SecureRandom.uuid }
    let(:expected_url) { "#{metadata_api_url}/services/#{service_id}/versions/#{version_id}" }
    let(:version_attributes) do
      {
        version_id:,
        created_at: '10:00am'
      }
    end
    let(:version) do
      MetadataApiClient::Version.new(version_attributes.stringify_keys)
    end

    before do
      stub_request(:get, expected_url)
        .to_return(status: 200, body: version_attributes.to_json, headers: {})
    end

    it 'returns the requested version of a service' do
      result = described_class.find(service_id:, version_id:)
      expect(result).to eq(version)
    end
  end

  describe '#version_id' do
    let(:version_id) { SecureRandom.uuid }
    let(:version_attributes) { { version_id: } }

    it 'returns the version id' do
      expect(described_class.new(version_attributes.stringify_keys).version_id).to eq(version_id)
    end
  end

  describe '#created_at' do
    let(:version_attributes) { { created_at: 'sometime' } }

    it 'returns the version id' do
      expect(described_class.new(version_attributes.stringify_keys).created_at).to eq('sometime')
    end
  end

  describe '.previous' do
    let(:expected_url) { "#{metadata_api_url}/services/#{service_id}/versions/previous" }
    let(:version_attributes) do
      {
        version_id: SecureRandom.uuid,
        created_at: '07:00pm'
      }
    end
    let(:version) do
      MetadataApiClient::Version.new(version_attributes.stringify_keys)
    end

    context 'if the metadata api service is working fine' do
      before do
        stub_request(:get, expected_url)
          .to_return(status: 200, body: version_attributes.to_json, headers: {})
      end

      it 'returns the response body with a correct format ' do
        result = described_class.previous(service_id)
        expect(result).to eq(version)
      end
    end

    context 'if there is a problem on the Metadata API' do
      let(:expected_body) do
        { 'message': ['Oh no!'] }
      end

      before do
        stub_request(:get, expected_url)
          .to_return(status: 400, body: expected_body.to_json, headers: {})
      end

      it 'assigns an error message' do
        expect(
          described_class.previous(service_id)
        ).to eq(
          MetadataApiClient::ErrorMessages.new(['Oh no!'])
        )
      end
    end
  end
end
