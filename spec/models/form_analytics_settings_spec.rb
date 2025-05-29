RSpec.describe FormAnalyticsSettings do
  subject(:form_analytics_settings) do
    described_class.new(base_params.merge(analytics_params))
  end
  let(:deployment_environment) { 'dev' }
  let(:enabled_test) { nil }
  let(:base_params) do
    {
      service_id: service.service_id,
      enabled_test:
    }
  end
  let(:analytics_params) { {} }

  context 'when enabled' do
    let(:enabled_test) { '1' }

    before do
      subject.validate
    end

    context 'when no analytics are present' do
      it 'returns invalid' do
        expect(subject).to_not be_valid
      end
    end

    context 'when at least one analytics is present' do
      let(:analytics_params) { { ga4_test: 'G-123456' } }

      it 'returns valid' do
        expect(subject).to be_valid
      end
    end
  end

  context 'when not enabled' do
    it 'is valid' do
      expect(subject.valid?).to be_truthy
    end
  end

  describe '#config_params' do
    let(:expected_config_params) { %i[gtm ga4] }

    it 'returns the config parameter keys' do
      expect(subject.config_params).to match_array(expected_config_params)
    end
  end

  describe '#config_names' do
    let(:expected_config_names) { %w[GTM GA4] }

    it 'returns the config parameter values' do
      expect(subject.config_names).to match_array(expected_config_names)
    end
  end

  describe '#enabled?' do
    context 'when enabled is present' do
      let(:enabled_test) { '1' }

      it 'returns truthy' do
        expect(subject.enabled?('test')).to be_truthy
      end
    end

    context 'when enabled is not present' do
      it 'returns falsey' do
        expect(subject.enabled?('test')).to be_falsey
      end
    end
  end

  describe '#check_enabled?' do
    context 'when enabled' do
      let(:enabled_test) { '1' }

      it 'returns truthy' do
        expect(subject.check_enabled?('test')).to be_truthy
      end
    end

    context 'when not enabled' do
      let(:enabled_test) { nil }

      context 'attribute has been previously configured' do
        before do
          create(:service_configuration, :gtm, :dev, service_id: service.service_id)
        end

        it 'returns truthy' do
          expect(subject.check_enabled?('test')).to be_truthy
        end
      end

      context 'attribute has not been previously configured' do
        it 'returns falsey' do
          expect(subject.check_enabled?('test')).to be_falsey
        end
      end
    end
  end

  describe '#saved_param' do
    context 'when attribute is present' do
      let(:analytics_params) { { ga4_test: 'G-123456' } }

      it 'returns the attribute value' do
        expect(subject.saved_param(:ga4, 'test')).to eq('G-123456')
      end
    end

    context 'when value has been saved to the db' do
      let!(:service_config) do
        create(:service_configuration, :dev, :gtm, service_id: service.service_id)
      end

      it 'returns the value in the db' do
        expect(subject.saved_param(:gtm, 'test')).to eq(service_config.decrypt_value)
      end
    end
  end

  %w[test live].each do |environment|
    describe "#gtm_#{environment}" do
      context 'when attribute is present' do
        let(:analytics_params) { { "gtm_#{environment}": 'GTM-123456' } }

        it 'returns the attribute value' do
          expect(subject.public_send("gtm_#{environment}")).to eq('GTM-123456')
        end
      end

      context 'when attribute is not present' do
        it 'returns nil' do
          expect(subject.public_send("gtm_#{environment}")).to be_nil
        end
      end
    end

    describe "#ga4_#{environment}" do
      context 'when attribute is present' do
        let(:analytics_params) { { "ga4_#{environment}": 'G-123456' } }

        it 'returns the attribute value' do
          expect(subject.public_send("ga4_#{environment}")).to eq('G-123456')
        end
      end

      context 'when attribute is not present' do
        it 'returns nil' do
          expect(subject.public_send("ga4_#{environment}")).to be_nil
        end
      end
    end
  end

  describe '#errors_present?' do
    let(:environment) { 'test' }

    before do
      subject.valid?
    end

    context 'when errors are present' do
      let(:enabled_test) { '1' }

      context 'enabled no params present' do
        it 'returns truthy' do
          expect(subject.errors_present?(environment)).to be_truthy
        end
      end

      context 'params present' do
        let(:analytics_params) { { "ga4_#{environment}": 'not-allowed' } }

        it 'returns truthy' do
          expect(subject.errors_present?(environment, "ga4_#{environment}")).to be_truthy
        end
      end
    end

    context 'when errors are not present' do
      let(:analytics_params) { { "gtm_#{environment}": 'GTM-123456' } }

      it 'returns falsey' do
        expect(subject.errors_present?(environment)).to be_falsey
      end
    end
  end
end
