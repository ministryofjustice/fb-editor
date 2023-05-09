RSpec.describe Admin::ApiSubmissionSettings, type: :model do
  describe 'validations' do
    subject(:api_submission_settings) do
      described_class.new(params.merge(service:))
    end
    let(:params) { {} }

    context 'deployment environment' do
      let(:service_output_json_key) { 'f89ea3f29cbdece2' }
      let(:service_output_json_endpoint) { 'valid.gov.uk' }
      let(:params) { { service_output_json_key:, service_output_json_endpoint: } }

      it 'allow dev and production' do
        should allow_values('dev', 'production').for(:deployment_environment)
      end

      it 'do not allow blank, nil, etc...' do
        should_not allow_values(nil, '', 'staging', 'live', 'test').for(:deployment_environment)
      end
    end

    context 'service_output_json_key' do
      let(:deployment_environment) { 'dev' }
      let(:service_output_json_endpoint) { 'valid .gov.uk' }
      let(:params) { { deployment_environment:, service_output_json_endpoint: } }

      it 'has to be 16 characters long' do
        should allow_values('98957af1a0424376', 'f89ea3f29cbdece2').for(:service_output_json_key)
      end

      # it 'do not allow anything else' do
      #   should_not allow_values(
      #     nil, 'abc', 'jdsiojd89ofi', 'c8c6f4710e6ebf28f89ea3f29cbdece2'
      #   ).for(:service_output_json_key)
      # end

      context 'key lenght is too short' do
        let(:deployment_environment) { 'dev' }
        let(:service_output_json_endpoint) { 'valid .gov.uk' }
        let(:service_output_json_key) { 'abc' }
        let(:params) { { deployment_environment:, service_output_json_endpoint:, service_output_json_key: } }
        let(:expected_error) { described_class::KEY_LENGTH_ERROR }

        it 'setting should be invalid' do
          expect(subject).to_not be_valid
        end

        it 'should have errors' do
          subject.valid?
          expect(subject.errors.first.type).to eq(expected_error)
        end
      end

      context 'key lenght is too long' do
        let(:deployment_environment) { 'dev' }
        let(:service_output_json_endpoint) { 'valid .gov.uk' }
        let(:service_output_json_key) { 'c8c6f4710e6ebf28f89ea3f29cbdece2' }
        let(:params) { { deployment_environment:, service_output_json_endpoint:, service_output_json_key: } }
        let(:expected_error) { described_class::KEY_LENGTH_ERROR }

        it 'setting should be invalid' do
          expect(subject).to_not be_valid
        end

        it 'should have errors' do
          subject.valid?
          expect(subject.errors.first.type).to eq(expected_error)
        end
      end
    end

    context 'service_output_json_endpoint' do
      let(:deployment_environment) { 'production' }
      let(:service_output_json_key) { 'f89ea3f29cbdece2' }
      let(:params) { { deployment_environment:, service_output_json_key: } }

      it 'has to be a url' do
        should allow_values(
          'http://this-valid-url.com', 'valid.gov.uk'
        ).for(:service_output_json_endpoint)
      end

      # it 'do not allow anything else' do
      #   should_not allow_values(
      #     nil, 'abc', 'not a valid url'
      #   ).for(:service_output_json_endpoint)
      # end
    end
  end
end
