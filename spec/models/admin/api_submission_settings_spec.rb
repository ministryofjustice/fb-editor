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
end
