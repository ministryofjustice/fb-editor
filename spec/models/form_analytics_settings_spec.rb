RSpec.describe FormAnalyticsSettings do
  subject(:form_analytics_settings) do
    described_class.new(base_params.merge(analytics_params))
  end
  let(:deployment_environment) { 'dev' }
  let(:enabled) { nil }
  let(:base_params) do
    {
      service_id: service.service_id,
      deployment_environment: deployment_environment,
      enabled: enabled
    }
  end
  let(:analytics_params) { {} }

  context 'when enabled' do
    let(:enabled) { '1' }

    before do
      subject.validate
    end

    context 'when no analytics are present' do
      it 'returns invalid' do
        expect(subject).to_not be_valid
      end
    end

    context 'when at least one analytics is present' do
      let(:analytics_params) { { ga4: 'G-123456' } }

      it 'returns valid' do
        expect(subject).to be_valid
      end
    end
  end

  context 'when not enabled' do
    it 'does not call any validators' do
      expect_any_instance_of(FormAnalyticsValidator).to_not receive(:validate)
      subject.validate
    end

    it 'does not add any errors' do
      subject.validate
      expect(subject.errors).to be_empty
    end
  end

  describe '#config_params' do
    let(:expected_config_params) { %i[ua gtm ga4] }

    it 'returns the config parameter keys' do
      expect(subject.config_params).to match_array(expected_config_params)
    end
  end

  describe '#config_names' do
    let(:expected_config_names) { %w[UA GTM GA4] }

    it 'returns the config parameter values' do
      expect(subject.config_names).to match_array(expected_config_names)
    end
  end

  describe '#enabled?' do
    context 'when enabled is present' do
      let(:enabled) { '1' }

      it 'returns truthy' do
        expect(subject.enabled?).to be_truthy
      end
    end

    context 'when enabled is not present' do
      it 'returns falsey' do
        expect(subject.enabled?).to be_falsey
      end
    end
  end

  describe '#check_enabled?' do
    context 'when enabled' do
      let(:enabled) { '1' }

      it 'returns truthy' do
        expect(subject.check_enabled?).to be_truthy
      end
    end

    context 'when not enabled' do
      let(:enabled) { nil }

      context 'attribute has been previously configured' do
        before do
          create(:service_configuration, :dev, :ua, service_id: service.service_id)
        end

        it 'returns truthy' do
          expect(subject.check_enabled?).to be_truthy
        end
      end

      context 'attribute has not been previously configured' do
        it 'returns falsey' do
          expect(subject.check_enabled?).to be_falsey
        end
      end
    end
  end

  describe '#params' do
    context 'when attribute is present' do
      let(:analytics_params) { { ga4: 'G-123456' } }

      it 'returns the attribute value' do
        expect(subject.params(:ga4)).to eq('G-123456')
      end
    end

    context 'when attribute is not present' do
      it 'returns nil' do
        expect(subject.params(:ua)).to be_nil
      end
    end

    context 'when attribute value is lower case' do
      let(:analytics_params) { { ua: 'ua-123456' } }

      it 'returns the uppercase value' do
        expect(subject.ua).to eq('UA-123456')
      end
    end
  end

  describe '#ua' do
    context 'when attribute is present' do
      let(:analytics_params) { { ua: 'UA-123456' } }

      it 'returns the attribute value' do
        expect(subject.ua).to eq('UA-123456')
      end
    end

    context 'when value has been saved to the db' do
      let!(:service_config) do
        create(:service_configuration, :dev, :ua, service_id: service.service_id)
      end

      it 'returns the value in the db' do
        expect(subject.ua).to eq(service_config.decrypt_value)
      end
    end
  end

  describe '#gtm' do
    context 'when attribute is present' do
      let(:analytics_params) { { gtm: 'GTM-123456' } }

      it 'returns the attribute value' do
        expect(subject.gtm).to eq('GTM-123456')
      end
    end

    context 'when value has been saved to the db' do
      let!(:service_config) do
        create(:service_configuration, :dev, :gtm, service_id: service.service_id)
      end

      it 'returns the value in the db' do
        expect(subject.gtm).to eq(service_config.decrypt_value)
      end
    end
  end

  describe '#ga4' do
    context 'when attribute is present' do
      let(:analytics_params) { { ga4: 'G-123456' } }

      it 'returns the attribute value' do
        expect(subject.ga4).to eq('G-123456')
      end
    end

    context 'when value has been saved to the db' do
      let!(:service_config) do
        create(:service_configuration, :dev, :ga4, service_id: service.service_id)
      end

      it 'returns the value in the db' do
        expect(subject.ga4).to eq(service_config.decrypt_value)
      end
    end
  end
end
