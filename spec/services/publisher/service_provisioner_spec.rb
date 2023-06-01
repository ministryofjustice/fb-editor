RSpec.describe Publisher::ServiceProvisioner do
  subject(:service_provisioner) { described_class.new(attributes) }
  let(:attributes) { {} }
  let(:service_metadata) { metadata_fixture(:version) }
  let(:global_service_configuration) do
    {
      strategy: {
        max_surge: '200%',
        max_unavailable: '25%'
      },
      readiness: {
        initial_delay_seconds: 50,
        period_seconds: 10,
        success_threshold: 5
      }
    }
  end
  include Shoulda::Matchers::ActiveModel

  before do
    allow(Rails.application.config).to receive(:global_service_configuration).and_return(global_service_configuration)
  end

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
        JSON.generate(service_metadata)
      )
    end
  end

  describe '#autocomplete_items' do
    let(:attributes) do
      { service_id: SecureRandom.uuid }
    end

    context 'when there are autocomplete items for a service' do
      let(:autocomplete_response) do
        {
          'items' => {
            SecureRandom.uuid => [
              { 'text' => 'some text', 'value' => 'some value' }
            ]
          }
        }
      end

      before do
        expect(MetadataApiClient::Items).to receive(:all)
          .with(service_id: attributes[:service_id])
          .and_return(MetadataApiClient::Items.new(autocomplete_response))
      end

      it 'generates the correct autocomplete items data structure' do
        expect(service_provisioner.autocomplete_items).to eq(
          autocomplete_response['items'].to_json
        )
      end
    end

    context 'when there are no autocomplete items for a service' do
      let(:autocomplete_response) { { 'items' => {} } }

      before do
        expect(MetadataApiClient::Items).to receive(:all)
          .with(service_id: attributes[:service_id])
          .and_return(MetadataApiClient::Items.new(autocomplete_response))
      end

      it 'generates the correct empty json string' do
        expect(service_provisioner.autocomplete_items).to eq('{}')
      end
    end

    context 'when the metadata api returns and error' do
      before do
        expect(MetadataApiClient::Items).to receive(:all)
          .with(service_id: attributes[:service_id])
          .and_return(MetadataApiClient::ErrorMessages.new('some error'))
      end

      it 'generates the correct empty json string' do
        expect(service_provisioner.autocomplete_items).to eq('{}')
      end
    end
  end

  describe '#autocomplete_ids' do
    let(:attributes) do
      { service_id: SecureRandom.uuid }
    end

    context 'when there are autocomplete item for a service' do
      let(:expected_ids) { [SecureRandom.uuid, SecureRandom.uuid, SecureRandom.uuid] }
      let(:autocomplete_response) do
        {
          'autocomplete_ids' => expected_ids
        }
      end

      before do
        expect(MetadataApiClient::Items).to receive(:all)
          .with(service_id: attributes[:service_id])
          .and_return(MetadataApiClient::Items.new(autocomplete_response))
      end

      it 'returns the autocomplete_ids' do
        expect(service_provisioner.autocomplete_ids).to eq(expected_ids)
      end
    end

    context 'when there are no autocomplete items for a service' do
      let(:autocomplete_response) { { 'autocomplete_ids' => [] } }

      before do
        expect(MetadataApiClient::Items).to receive(:all)
          .with(service_id: attributes[:service_id])
          .and_return(MetadataApiClient::Items.new(autocomplete_response))
      end

      it 'generates the correct empty json string' do
        expect(service_provisioner.autocomplete_ids).to eq([])
      end
    end

    context 'when the metadata api returns and error' do
      before do
        expect(MetadataApiClient::Items).to receive(:all)
          .with(service_id: attributes[:service_id])
          .and_return(MetadataApiClient::ErrorMessages.new('some error'))
      end

      it 'generates the correct empty json string' do
        expect(service_provisioner.autocomplete_ids).to eq([])
      end
    end
  end

  describe '#service_slug' do
    let(:service_id) { SecureRandom.uuid }
    let(:attributes) { { service_id: } }

    context 'if SERVICE_SLUG does not exist' do
      before do
        expect(MetadataApiClient::Version).to receive(:find)
          .with(service_id: attributes[:service_id], version_id: attributes[:version_id])
          .and_return(MetadataApiClient::Version.new(service_metadata))
      end

      it 'returns slug using the service name' do
        expect(service_provisioner.service_slug).to eq('version-fixture')
      end
    end

    context 'if SERVICE_SLUG does exist' do
      let!(:service_config) do
        create(
          :service_configuration,
          :dev,
          :service_slug,
          service_id:
        )&.decrypt_value
      end

      before do
        allow_any_instance_of(Publisher::ServiceProvisioner).to receive(:service_slug_config).and_return(service_config)
      end

      it 'returns slug using the service name' do
        expect(service_provisioner.service_slug).to eq('eat-slugs-malfoy')
      end
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

  describe '#strategy_max_surge' do
    it 'returns the max surge configuration' do
      expect(service_provisioner.strategy_max_surge).to eq('200%')
    end
  end

  describe '#strategy_max_unavailable' do
    it 'returns the max unavailable configuration' do
      expect(service_provisioner.strategy_max_unavailable).to eq('25%')
    end
  end

  describe '#readiness_initial_delay' do
    it 'returns the initial delay configuration' do
      expect(service_provisioner.readiness_initial_delay).to eq(50)
    end
  end

  describe '#readiness_period' do
    it 'returns the readiness period configuration' do
      expect(service_provisioner.readiness_period).to eq(10)
    end
  end

  describe '#readiness_success_threshold' do
    it 'returns the success threshold configuration' do
      expect(service_provisioner.readiness_success_threshold).to eq(5)
    end
  end

  describe '#config_map' do
    let(:service_id) { SecureRandom.uuid }
    let(:version_id) { SecureRandom.uuid }
    let(:attributes) do
      {
        service_id:,
        version_id:,
        platform_environment: 'test',
        deployment_environment: 'dev',
        service_configuration: [
          build(:service_configuration, :encoded_public_key, deployment_environment: 'dev', service_id:),
          build(:service_configuration, :username, deployment_environment: 'dev', service_id:),
          build(:service_configuration, :service_email_from, deployment_environment: 'dev', service_id:),
          build(:service_configuration, :maintenance_page_heading, deployment_environment: 'dev', service_id:),
          build(:service_configuration, :payment_link_url, deployment_environment: 'dev', service_id:)
        ]
      }
    end

    context 'secrets' do
      it 'rejects secrets' do
        expect(service_provisioner.config_map.map(&:name)).to_not include('BASIC_AUTH_USER')
        expect(service_provisioner.config_map.map(&:name)).to include('ENCODED_PUBLIC_KEY')
      end
    end

    context 'do_not_send_submission' do
      context 'when send_email is present' do
        before do
          create(:submission_setting, :send_email, service_id:, deployment_environment: 'dev')
        end

        it 'should include submission configuration' do
          expect(service_provisioner.config_map.map(&:name)).to include('SERVICE_EMAIL_FROM')
        end

        it 'does not include maintenance page config' do
          expect(service_provisioner.config_map.map(&:name)).to_not include('MAINTENANCE_PAGE_HEADING')
        end
      end

      context 'when send_email is not present' do
        it 'should include submission configuration' do
          expect(service_provisioner.config_map.map(&:name)).to_not include('SERVICE_EMAIL_FROM')
        end
      end
    end

    context 'not_in_maintenance_mode' do
      context 'when in maintenance mode' do
        before do
          create(:service_configuration, :maintenance_mode, service_id:, deployment_environment: 'dev')
        end

        it 'should include the maintenance config' do
          expect(service_provisioner.config_map.map(&:name)).to include('MAINTENANCE_PAGE_HEADING')
        end
      end

      context 'when not in maintenance mode' do
        it 'should not include the maintenance config' do
          expect(service_provisioner.config_map.map(&:name)).to_not include('MAINTENANCE_PAGE_HEADING')
        end
      end
    end

    context 'do_not_inject_payment_link' do
      context 'when payment_link is present' do
        before do
          create(:submission_setting, :payment_link, service_id:, deployment_environment: 'dev')
        end

        it 'should include submission configuration' do
          expect(service_provisioner.config_map.map(&:name)).to include('PAYMENT_LINK')
        end
      end

      context 'when payment link is not present' do
        it 'should include submission configuration' do
          expect(service_provisioner.config_map.map(&:name)).to_not include('PAYMENT_LINK')
        end
      end
    end
  end

  describe '#replicas' do
    let(:service_namespace_configuration) do
      {
        test_production: { hpa: { min_replicas: 1 } },
        live_dev: { hpa: { min_replicas: 1 } },
        live_production: { hpa: { min_replicas: 2 } }
      }
    end

    before do
      allow(Rails.application.config).to receive(:service_namespace_configuration).and_return(service_namespace_configuration)
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
    let(:service_namespace_configuration) do
      {
        test_dev: { hpa: { max_replicas: 7 } },
        live_production: { hpa: { max_replicas: 20 } }
      }
    end

    before do
      allow(Rails.application.config).to receive(:service_namespace_configuration).and_return(service_namespace_configuration)
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
    let(:service_namespace_configuration) do
      { live_production: { hpa: { target_cpu_utilisation: 50 } } }
    end
    let(:attributes) do
      { platform_environment: 'live', deployment_environment: 'production' }
    end

    before do
      allow(Rails.application.config).to receive(:service_namespace_configuration).and_return(service_namespace_configuration)
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
