require 'rails_helper'

RSpec.describe ApiSubmissionSettings, type: :model do
  describe 'validations' do
    context 'deployment environment' do
      it 'do not allow blank' do
        should_not allow_values('').for(:deployment_environment)
      end
    end
  end

  describe '#valid?' do
    subject(:api_submission_settings) do
      described_class.new(
        params.merge(service:)
      )
    end

    context 'deployment environment' do
      it 'allow dev and production' do
        should allow_values('dev', 'production').for(:deployment_environment)
      end

      it 'do not allow enything else' do
        should_not allow_values(
          nil, '', 'something-else', 'staging', 'live', 'test'
        ).for(:deployment_environment)
      end
    end

    let(:service_output_json_endpoint) { api_submission_settings.default_value('service_output_json_endpoint') }
    let(:service_output_json_key) { api_submission_settings.default_value('service_output_json_key') }

    context 'service_output_json_key' do
      it 'has to be 16 characters long' do
        should allow_values(
          'f89ea3f29cbdece2', '98957af1a0424376'
        ).for(:service_output_json_key)
      end

      it 'do not allow enything else' do
        should_not allow_values(
          nil, '', 'abc', 'jdsiojd89ofi', 'c8c6f4710e6ebf28f89ea3f29cbdece2'
        ).for(:service_output_json_key)
      end
    end
  end
end
