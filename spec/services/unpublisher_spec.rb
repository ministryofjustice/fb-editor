RSpec.describe Unpublisher do
  subject(:unpublisher) { described_class.new(attributes) }
  let(:attributes) do
    {
      publish_service:,
      platform_environment:,
      service_slug:,
      adapter: fake_adapter
    }
  end
  let(:fake_adapter) do
    # rubocop:disable Lint/ConstantDefinitionInBlock
    class FakeAdapter
      def initialize(publish_service:, platform_environment:, service_slug:); end

      def unpublishing; end

      def unpublished; end
    end
    FakeAdapter
    # rubocop:enable Lint/ConstantDefinitionInBlock
  end

  describe '#call' do
    let(:fake_adapter_instance) { double(unpublishing: true) }
    let(:publish_service) do
      create(
        :publish_service,
        :dev,
        service_id: SecureRandom.uuid,
        status: 'queued'
      )
    end
    let(:platform_environment) { 'dev' }
    let(:service_slug) { 'sluggy-mcslugface' }
    let(:adapter_attributes) { attributes.reject { |k, _| k == :adapter } }

    it 'calls unpublishing on adapter' do
      expect(fake_adapter).to receive(:new).with(
        adapter_attributes
      ).and_return(fake_adapter_instance)
      expect(fake_adapter_instance).to receive(:unpublishing)
      unpublisher.call(steps: %w[unpublishing])
    end
  end
end
