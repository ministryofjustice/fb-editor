RSpec.describe Publisher::UptimeEligibility do
  subject :pingdom_eligibility do
    described_class.new(publish_service)
  end

  before do
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with('PLATFORM_ENV').and_return('live')
  end

  describe '#can_create?' do
    context 'when live production' do
      let(:publish_service) { build(:publish_service, :production) }

      context 'when there is no uptime check' do
        before do
          UptimeCheck.delete_all
        end

        it 'returns true' do
          expect(pingdom_eligibility.can_create?).to be_truthy
        end
      end

      context 'when there is an uptime check' do
        before do
          create(:uptime_check, service_id: publish_service.service_id)
        end

        it 'returns false' do
          expect(pingdom_eligibility.can_create?).to be_falsey
        end
      end
    end

    context 'when not live production' do
      let(:publish_service) { build(:publish_service, :dev) }

      it 'returns false' do
        expect(pingdom_eligibility.can_create?).to be_falsey
      end
    end
  end

  describe '#can_destroy?' do
    context 'when live production' do
      let(:publish_service) { build(:publish_service, :production) }

      context 'when there is no uptime check' do
        before do
          UptimeCheck.delete_all
        end

        it 'returns false' do
          expect(pingdom_eligibility.can_destroy?).to be_falsey
        end
      end

      context 'when there is an uptime check' do
        before do
          create(:uptime_check, service_id: publish_service.service_id)
        end

        it 'returns false' do
          expect(pingdom_eligibility.can_destroy?).to be_truthy
        end
      end
    end

    context 'when not live production' do
      let(:publish_service) { build(:publish_service, :dev) }

      it 'returns false' do
        expect(pingdom_eligibility.can_destroy?).to be_falsey
      end
    end
  end
end
