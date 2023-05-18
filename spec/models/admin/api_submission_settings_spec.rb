RSpec.describe Admin::ApiSubmissionSettings, type: :model do
  describe 'validations' do
    subject(:api_submission_settings) do
      described_class.new(params.merge(service:))
    end
    let(:params) { {} }
    let(:service_output_json_key) { 'f89ea3f29cbdece2x' }

    context 'deployment environment' do
      let(:service_output_json_endpoint) { 'valid.gov.uk' }
      let(:params) { { service_output_json_key:, service_output_json_endpoint: } }

      it 'allow dev and production' do
        should allow_values('dev', 'production').for(:deployment_environment)
      end

      it 'do not allow blank, nil, etc...' do
        should_not allow_values(nil, '', 'staging', 'live', 'test').for(:deployment_environment)
      end
    end

    context 'service_output_json_endpoint' do
      let(:deployment_environment) { 'production' }
      let(:params) { { deployment_environment:, service_output_json_endpoint:, service_output_json_key: } }
      let(:expected_error) { described_class::URL_ERROR }

      context 'it is a correct url' do
        let(:service_output_json_endpoint) { 'http://this-valid-url.com' }

        it 'setting should be valid' do
          expect(subject).to be_valid
        end
      end

      context 'is empty to reset configuration' do
        let(:service_output_json_endpoint) { '' }

        it 'is valid' do
          expect(subject).to be_valid
        end
      end

      context 'url field doesn\'t have a scheme prefix' do
        let(:service_output_json_endpoint) { 'valid.gov.uk' }

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
