RSpec.describe FormAnalyticsValidator do
  subject(:form_analytics_settings) do
    FormAnalyticsSettings.new(base_params.merge(analytics_params))
  end
  let(:deployment_environment) { 'dev' }
  let(:enabled) { '1' }
  let(:base_params) do
    {
      deployment_environment: deployment_environment,
      enabled: enabled
    }
  end
  let(:analytics_params) do
    {
      ua: 'UA-123456',
      gtm: 'GTM-123456',
      ga4: 'G-123456'
    }
  end

  describe '#validate' do
    before { subject.validate }

    context 'when all analytics are valid' do
      it 'returns valid' do
        expect(subject).to be_valid
      end
    end

    context 'when universal analytics is invalid' do
      let(:analytics_params) { { ua: 'not-a-universal-analytics-id' } }

      it 'returns invalid' do
        expect(subject).to_not be_valid
      end
    end

    context 'when google tag manager is invalid' do
      let(:analytics_params) { { gtm: 'not-a-google-tag-manager-id' } }

      it 'returns invalid' do
        expect(subject).to_not be_valid
      end
    end

    context 'when google analytics 4 is invalid' do
      let(:analytics_params) { { ga4: 'not-a-google-analytics-4-id' } }

      it 'returns invalid' do
        expect(subject).to_not be_valid
      end
    end
  end
end
