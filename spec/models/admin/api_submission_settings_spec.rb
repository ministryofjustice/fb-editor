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
      let(:service_output_json_endpoint) { 'http://this-valid-url.com' }
      let(:params) { { deployment_environment:, service_output_json_endpoint:, service_output_json_key: } }
      let(:expected_error) { described_class::KEY_LENGTH_ERROR }

      context 'has to be 16 characters long' do
        let(:service_output_json_key) { '98957af1a0424376' }

        it 'is valid' do
          expect(subject).to be_valid
        end
      end

      context 'key lenght is too short' do
        let(:service_output_json_key) { 'abc' }

        it 'setting should be invalid' do
          expect(subject).to_not be_valid
        end

        it 'should have errors' do
          subject.valid?
          expect(subject.errors.first.type).to eq(expected_error)
        end
      end

      context 'key lenght is too long' do
        let(:service_output_json_key) { 'c8c6f4710e6ebf28f89ea3f29cbdece2' }
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
      let(:params) { { deployment_environment:, service_output_json_endpoint:, service_output_json_key: } }

      context 'it is a correct url' do
        let(:service_output_json_endpoint) { 'http://this-valid-url.com' }

        it 'setting should be valid' do
          expect(subject).to be_valid
        end
      end

      context 'url field doesn\'t have a scheme prefix' do
        let(:deployment_environment) { 'dev' }
        let(:service_output_json_key) { 'f89ea3f29cbdece2' }
        let(:service_output_json_endpoint) { 'valid.gov.uk' }
        let(:params) { { deployment_environment:, service_output_json_endpoint:, service_output_json_key: } }
        let(:expected_error) { described_class::URL_ERROR }

        it 'setting should be invalid' do
          expect(subject).to_not be_valid
        end

        it 'should have errors' do
          subject.valid?
          expect(subject.errors.first.type).to eq(expected_error)
        end
      end
    end
  end
end
