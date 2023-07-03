RSpec.describe Uptime do
  subject(:uptime) { described_class.new(**attributes) }
  let(:service_id) { SecureRandom.uuid }
  let(:service_name) { 'Apply To Use An Apply For Service' }
  let(:host) { 'a-different-url' }
  let(:attributes) do
    {
      service_id:,
      check_id:,
      service_name:,
      host:,
      adapter: fake_uptime_adapter
    }
  end
  let(:fake_uptime_adapter) do
    # rubocop:disable Lint/ConstantDefinitionInBlock
    class FakeUptimeAdapter
      def check; end

      def create(service_name, host, service_id); end

      def update(check_id, service_name, host); end

      def destroy(check_id); end

      def exists?(service_id); end
    end
    FakeUptimeAdapter
    # rubocop:enable Lint/ConstantDefinitionInBlock
  end
  let(:check_id) { 'some-check-id' }

  describe '#create' do
    context 'when no uptime check exists for service' do
      it 'calls create on the adapter' do
        expect_any_instance_of(fake_uptime_adapter).to receive(:create).with(service_name, host, service_id).and_return(check_id)
        uptime.create
      end

      it 'creates a new uptime check in the database' do
        allow_any_instance_of(fake_uptime_adapter).to receive(:create).and_return(check_id)
        uptime.create

        expect(UptimeCheck.find_by(service_id:).check_id).to eq(check_id)
      end

      it 'instruments active support notification' do
        expect(ActiveSupport::Notifications).to receive(:instrument).with('uptime.create')
        uptime.create
      end
    end

    context 'when uptime check exists for service' do
      before do
        create(:uptime_check, service_id:, check_id:)
      end

      it 'calls update' do
        expect_any_instance_of(fake_uptime_adapter).to receive(:exists?).with(service_id).and_return(true)
        expect(uptime).to receive(:update)
        uptime.create
      end

      it 'does not call create on the adapter' do
        expect_any_instance_of(fake_uptime_adapter).not_to receive(:create)
      end
    end
  end

  describe '#update' do
    before do
      create(:uptime_check, service_id:, check_id:)
    end

    it 'calls update on the adapter' do
      expect_any_instance_of(fake_uptime_adapter).to receive(:update).with(check_id, service_name, host)
      uptime.update
    end

    it 'instruments active support notification' do
      expect(ActiveSupport::Notifications).to receive(:instrument).with('uptime.update')
      uptime.update
    end
  end

  describe '#destroy' do
    let(:attributes) do
      {
        service_id: nil,
        check_id:,
        service_name: nil,
        host: nil,
        adapter: fake_uptime_adapter
      }
    end

    before do
      create(:uptime_check, service_id:, check_id:)
    end

    it 'calls destroy on the adapter' do
      expect_any_instance_of(fake_uptime_adapter).to receive(:destroy).with(check_id)
      uptime.destroy
    end

    it 'destroys the uptime check in the database' do
      uptime.destroy
      expect(UptimeCheck.find_by(service_id:)).to be_nil
    end

    it 'instruments active support notification' do
      expect(ActiveSupport::Notifications).to receive(:instrument).with('uptime.destroy')
      uptime.destroy
    end
  end
end
