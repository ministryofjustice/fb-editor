RSpec.describe Publisher::AfterCompletion do
  subject { described_class.new(service_provisioner:) }

  let(:service_provisioner) { Publisher::ServiceProvisioner.new(args) }
  let(:service_metadata) { metadata_fixture(:version) }

  let(:service_id) { service_metadata['service_id'] }
  let(:version_id) { service_metadata['version_id'] }
  let(:platform_environment) { 'test' }

  let(:args) do
    {
      service_id:,
      version_id:,
      deployment_environment:,
      platform_environment:
    }
  end

  before do
    allow(
      MetadataApiClient::Version
    ).to receive(:find).with(service_id:, version_id:).and_return(
      MetadataApiClient::Version.new(service_metadata)
    )
  end

  describe '#call' do
    context 'when deployment env is `production`' do
      let(:deployment_environment) { 'production' }

      it 'does not trigger the email' do
        expect(PublisherMailer).not_to receive(:first_time_publish_to_test)
        subject.call
      end
    end

    context 'when deployment env is `dev`' do
      let(:deployment_environment) { 'dev' }
      let(:completed_scope) { double('completed_scope') }

      before do
        allow(PublishService).to receive(:completed).and_return(completed_scope)
        allow(completed_scope).to receive(:where).with(
          service_id:, deployment_environment:
        ).and_return(results_double)
      end

      context 'when this service has been already published before' do
        let(:results_double) { [Object, Object] }

        it 'does not trigger the email' do
          expect(PublisherMailer).not_to receive(:first_time_publish_to_test)
          subject.call
        end
      end

      context 'when this service is being published for the first time' do
        let(:results_double) { [Object] } # just one result, corresponding to the current publishing

        let(:user) { instance_double(User) }
        let(:form_name) { 'Version Fixture' }
        let(:form_url) { 'https://version-fixture.dev.test.form.service.justice.gov.uk' }

        it 'triggers the email' do
          expect(User).to receive(:find).with(service_metadata['created_by']).and_return(user)

          expect(
            PublisherMailer
          ).to receive(:first_time_publish_to_test).with(
            user:, form_name:, form_url:
          ).and_return(double.as_null_object)

          subject.call
        end
      end
    end
  end
end
