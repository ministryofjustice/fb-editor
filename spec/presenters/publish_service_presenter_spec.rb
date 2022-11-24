RSpec.describe PublishServicePresenter do
  let(:view) do
    PublishController.new.view_context
  end

  # describe '.hostname_for' do
  #   subject(:hostname) do
  #     described_class.hostname_for(
  #       deployment_environment: deployment_environment,
  #       view: view
  #     )
  #   end

  #   let(:params) { { id: service.service_id } }
  #   let(:expected_hostname) do
  #     %(<a target=\"_blank\" class=\"govuk-link\" rel=\"noopener\" href=\"https://version-fixture.dev.test.form.service.justice.gov.uk\">https://version-fixture.dev.test.form.service.justice.gov.uk</a>)
  #   end

  #   before do
  #     allow(view).to receive(:service).and_return(service)
  #   end

  #   context 'when there is a published service' do
  #     context 'when same deployment_environment' do
  #       let(:deployment_environment) { 'dev' }
  #       let!(:publish_service) do
  #         create(:publish_service, :dev, :completed, service_id: service.service_id)
  #       end

  #       it 'returns hostname link' do
  #         expect(hostname).to eq(expected_hostname)
  #       end
  #     end

  #     context 'when not the same deployment_environment' do
  #       let(:deployment_environment) { 'production' }
  #       let!(:publish_service) do
  #         create(:publish_service, :dev, :completed, service_id: service.service_id)
  #       end

  #       it 'returns nil' do
  #         expect(hostname).to be_nil
  #       end
  #     end
  #   end

  #   context 'when is not completed' do
  #     let(:deployment_environment) { 'dev' }
  #     let!(:publish_service) do
  #       create(:publish_service, :dev, :queued, service_id: service.service_id)
  #     end

  #     it 'always shows the hostname' do
  #       expect(hostname).to eq(expected_hostname)
  #     end
  #   end

  #   context 'when there is not a published service' do
  #     let(:deployment_environment) { 'dev' }

  #     it 'returns nil' do
  #       expect(hostname).to be_nil
  #     end
  #   end
  # end
end
