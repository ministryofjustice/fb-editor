RSpec.describe ApiSubmissionSettings, type: :model do
  describe 'validations' do
    context 'deployment environment' do
      it 'do not allow blank' do
        should_not allow_values('').for(:deployment_environment)
      end
    end
  end
end
