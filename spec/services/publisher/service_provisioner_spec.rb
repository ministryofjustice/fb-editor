RSpec.describe Publisher::ServiceProvisioner do
  subject(:service_provisioner) { described_class.new(attributes) }
  let(:attributes) { {} }
  let(:service_metadata) { metadata_fixture(:version) }
  include Shoulda::Matchers::ActiveModel

  describe '#service_metadata' do
    let(:attributes) do
      { service_id: SecureRandom.uuid, version_id: SecureRandom.uuid }
    end

    before do
      expect(MetadataApiClient::Version).to receive(:find)
        .with(service_id: attributes[:service_id], version_id: attributes[:version_id])
        .and_return(MetadataApiClient::Version.new(service_metadata))
    end

    it 'returns slug using the service name' do
      expect(service_provisioner.service_metadata).to eq(
        JSON.generate(service_metadata).inspect
      )
    end
  end

  describe '#service_slug' do
    let(:attributes) { { service_id: SecureRandom.uuid } }

    before do
      expect(MetadataApiClient::Version).to receive(:find)
        .with(service_id: attributes[:service_id], version_id: attributes[:version_id])
        .and_return(MetadataApiClient::Version.new(service_metadata))
    end

    it 'returns slug using the service name' do
      expect(service_provisioner.service_slug).to eq('version-fixture')
    end
  end

  describe '#namespace' do
    let(:attributes) do
      { platform_environment: 'local', deployment_environment: 'dev' }
    end

    it 'returns services namespace' do
      expect(service_provisioner.namespace).to eq('formbuilder-services-local-dev')
    end
  end

  describe '#config_map_name' do
    before do
      expect(service_provisioner).to receive(:service_slug).and_return(
        'mace-windu'
      )
    end

    it 'returns the config map name prefixed by service name' do
      expect(service_provisioner.config_map_name).to eq(
        'fb-mace-windu-config-map'
      )
    end
  end

  describe '#replicas' do
    let(:services_hpa) do
      {
        test_production: { min_replicas: 1 },
        live_dev: { min_replicas: 1 },
        live_production: { min_replicas: 2 }
      }
    end

    before do
      allow(Rails.application.config).to receive(:services_hpa).and_return(services_hpa)
    end

    context 'when live production environment' do
      let(:attributes) do
        { platform_environment: 'live', deployment_environment: 'production' }
      end

      it 'returns 2 replicas' do
        expect(service_provisioner.replicas).to be(2)
      end
    end

    context 'when live dev environment' do
      let(:attributes) do
        { platform_environment: 'live', deployment_environment: 'dev' }
      end

      it 'returns 1 replica' do
        expect(service_provisioner.replicas).to be(1)
      end
    end

    context 'when other environments' do
      let(:attributes) do
        { platform_environment: 'test', deployment_environment: 'production' }
      end

      it 'returns 1 replica' do
        expect(service_provisioner.replicas).to be(1)
      end
    end
  end

  describe '#max_replicas' do
    let(:services_hpa) do
      {
        test_dev: { max_replicas: 7 },
        live_production: { max_replicas: 20 }
      }
    end

    before do
      allow(Rails.application.config).to receive(:services_hpa).and_return(services_hpa)
    end

    context 'when live production environment' do
      let(:attributes) do
        { platform_environment: 'live', deployment_environment: 'production' }
      end

      it 'returns the correct number of replicas' do
        expect(service_provisioner.max_replicas).to be(20)
      end
    end

    context 'when other environments' do
      let(:attributes) do
        { platform_environment: 'test', deployment_environment: 'dev' }
      end

      it 'returns the correct number of replicas' do
        expect(service_provisioner.max_replicas).to be(7)
      end
    end
  end

  describe '#target_cpu_utilisation' do
    let(:services_hpa) do
      { live_production: { target_cpu_utilisation: 50 } }
    end
    let(:attributes) do
      { platform_environment: 'live', deployment_environment: 'production' }
    end

    before do
      allow(Rails.application.config).to receive(:services_hpa).and_return(services_hpa)
    end

    it 'returns the correct value for target cpu utilisation' do
      expect(service_provisioner.target_cpu_utilisation).to be(50)
    end
  end

  describe '#hostname' do
    before do
      allow(service_provisioner).to receive(:service_slug).and_return(
        'padme'
      )
    end

    context 'when live environment' do
      context 'when dev environment' do
        let(:attributes) do
          { platform_environment: 'live', deployment_environment: 'dev' }
        end

        it 'returns hostname with dev prefix' do
          expect(service_provisioner.hostname).to eq(
            'padme.dev.form.service.justice.gov.uk'
          )
        end
      end

      context 'when production environment' do
        let(:attributes) do
          { platform_environment: 'live', deployment_environment: 'production' }
        end

        it 'returns hostname' do
          expect(service_provisioner.hostname).to eq(
            'padme.form.service.justice.gov.uk'
          )
        end
      end
    end

    context 'when test environment' do
      context 'when dev environment' do
        let(:attributes) do
          { platform_environment: 'test', deployment_environment: 'dev' }
        end

        it 'returns hostname with dev prefix' do
          expect(service_provisioner.hostname).to eq(
            'padme.dev.test.form.service.justice.gov.uk'
          )
        end
      end

      context 'when production environment' do
        let(:attributes) do
          { platform_environment: 'test', deployment_environment: 'production' }
        end

        it 'returns hostname with dev prefix' do
          expect(service_provisioner.hostname).to eq(
            'padme.test.form.service.justice.gov.uk'
          )
        end
      end
    end
  end

  describe '#user_datastore_url' do
    context 'when live environment' do
      context 'when dev environment' do
        let(:attributes) do
          { platform_environment: 'live', deployment_environment: 'dev' }
        end

        it 'returns hostname with live dev prefix' do
          expect(service_provisioner.user_datastore_url).to eq(
            'http://fb-user-datastore-api-svc-live-dev.formbuilder-platform-live-dev/'
          )
        end
      end

      context 'when production environment' do
        let(:attributes) do
          { platform_environment: 'live', deployment_environment: 'production' }
        end

        it 'returns hostname' do
          expect(service_provisioner.user_datastore_url).to eq(
            'http://fb-user-datastore-api-svc-live-production.formbuilder-platform-live-production/'
          )
        end
      end
    end

    context 'when test environment' do
      context 'when dev environment' do
        let(:attributes) do
          { platform_environment: 'test', deployment_environment: 'dev' }
        end

        it 'returns hostname with test dev prefix' do
          expect(service_provisioner.user_datastore_url).to eq(
            'http://fb-user-datastore-api-svc-test-dev.formbuilder-platform-test-dev/'
          )
        end
      end

      context 'when production environment' do
        let(:attributes) do
          { platform_environment: 'test', deployment_environment: 'production' }
        end

        it 'returns hostname with dev prefix' do
          expect(service_provisioner.user_datastore_url).to eq(
            'http://fb-user-datastore-api-svc-test-production.formbuilder-platform-test-production/'
          )
        end
      end
    end
  end

  describe '#secret_key_base' do
    let(:secret_key_base) do
      '95ccf88919d3a4feff3faa1a3f8fa1b195b82b6abac544ba248eaa93aee18e12fec54847793d60ed7e7413794466e2322bf3157170dc9eca7fd56b9689199d04'
    end

    it 'returns a hex 64 bytes' do
      expect(SecureRandom).to receive(:hex).with(64).and_return(secret_key_base)
      expect(service_provisioner.secret_key_base).to eq(secret_key_base)
    end
  end

  describe '#valid?' do
    context 'blank services' do
      it 'does not allow blank services' do
        should_not allow_values(nil, '').for(:service_id)
      end
    end

    context 'blank version' do
      it 'does not allow blank version' do
        should_not allow_values(nil, '').for(:version_id)
      end
    end

    context 'blank platform environment' do
      it 'does not allow' do
        should_not allow_values(nil, '').for(:platform_environment)
      end
    end

    context 'blank deployment environment' do
      it 'does not allow' do
        should_not allow_values(nil, '').for(:deployment_environment)
      end
    end

    context 'blank private public key' do
      it 'does not allow' do
        should_not allow_values([]).for(:service_configuration)
      end
    end

    context 'does not include private public key' do
      it 'does not allow' do
        should_not allow_values(
          [double(name: 'something-else')]
        ).for(:service_configuration)
      end
    end
  end

  describe '#service_sentry_dsn' do
    before do
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with('SERVICE_SENTRY_DSN_TEST').and_return('test')
      allow(ENV).to receive(:[]).with('SERVICE_SENTRY_DSN_LIVE').and_return('live')
    end

    context 'not live production' do
      not_live_production = [
        { platform_environment: 'test', deployment_environment: 'dev' },
        { platform_environment: 'test', deployment_environment: 'production' },
        { platform_environment: 'live', deployment_environment: 'dev' }
      ]

      not_live_production.each do |platform_deployment|
        context "#{platform_deployment[:platform_environment]}-#{platform_deployment[:deployment_environment]}" do
          let(:attributes) { platform_deployment }

          it 'creates the correct platform deployment' do
            expect(service_provisioner.service_sentry_dsn).to eq('test')
          end
        end
      end
    end

    context 'live production' do
      let(:attributes) do
        { platform_environment: 'live', deployment_environment: 'production' }
      end

      it 'creates the correct platform deployment' do
        expect(service_provisioner.service_sentry_dsn).to eq('live')
      end
    end
  end
end
