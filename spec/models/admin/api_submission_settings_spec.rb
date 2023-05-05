RSpec.describe Admin::ApiSubmissionSettings, type: :model do
  describe 'validations' do
    context 'deployment environment' do
      it 'allow dev and production' do
        should allow_values('dev', 'production').for(:deployment_environment)
      end

      it 'do not allow blank, nil, etc...' do
        should_not allow_values(nil, '', 'staging', 'live', 'test').for(:deployment_environment)
      end
    end

    context 'service_output_json_key' do
      subject(:api_submission_settings) do
        described_class.new(
          params.merge(service:)
        )
      end
      let(:params) { {deployment_environment: 'dev'} }
      let(:service_output_json_key) { api_submission_settings.default_value('service_output_json_key') }

      it 'has to be 16 characters long' do
        should allow_values(
          'f89ea3f29cbdece2', '98957af1a0424376'
        ).for(:service_output_json_key)
      end

      # it 'do not allow anything else' do
      #   should_not allow_values(
      #     nil, 'abc', 'jdsiojd89ofi', 'c8c6f4710e6ebf28f89ea3f29cbdece2'
      #   ).for(:service_output_json_key)
      # end

      context 'key lenght is not right' do
        let(:service_output_json_key) { 'abc' }
        let(:expected_error) { 'Key length must be 16.' }

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
