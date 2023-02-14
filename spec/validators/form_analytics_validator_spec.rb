RSpec.describe FormAnalyticsValidator do
  subject(:form_analytics_settings) do
    FormAnalyticsSettings.new(base_params.merge(analytics_params))
  end
  let(:enabled_test) { '1' }
  let(:base_params) do
    {
      service_id: service.service_id,
      enabled_test:
    }
  end
  let(:analytics_params) do
    {
      ua_test: 'UA-123456',
      gtm_live: 'GTM-123456',
      ga4_live: 'G-123456'
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
      let(:analytics_params) { { ua_live: 'not-a-universal-analytics-id' } }

      it 'returns invalid' do
        expect(subject).to_not be_valid
      end
    end

    context 'when google tag manager is invalid' do
      let(:analytics_params) { { gtm_test: 'not-a-google-tag-manager-id' } }

      it 'returns invalid' do
        expect(subject).to_not be_valid
      end
    end

    context 'when google analytics 4 is invalid' do
      let(:analytics_params) { { ga4_test: 'not-a-google-analytics-4-id' } }

      it 'returns invalid' do
        expect(subject).to_not be_valid
      end
    end

    context 'when not enabled' do
      let(:enabled_test) { nil }
      let(:analytics_params) { { gtm_test: 'not-a-google-tag-manager-id' } }

      it 'does not add any errors' do
        expect(subject).to be_valid
      end
    end
  end
end
