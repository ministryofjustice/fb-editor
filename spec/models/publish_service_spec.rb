RSpec.describe PublishService, type: :model do
  describe 'validations' do
    context 'user id' do
      it 'do not allow blank' do
        should_not allow_values('').for(:user_id)
      end
    end

    context 'version id' do
      it 'do not allow blank' do
        should_not allow_values('').for(:version_id)
      end
    end

    context 'deployment environment' do
      it 'allow dev and production' do
        should allow_values('dev', 'production').for(:deployment_environment)
      end

      it 'do not allow enything else' do
        should_not allow_values(
          '', 'something-else', 'staging', 'live', 'test'
        ).for(:deployment_environment)
      end
    end

    context 'status' do
      it 'allow queued and completed' do
        should allow_values(
          'queued',
          'pre_publishing',
          'publishing',
          'post_publishing',
          'completed',
          'unpublishing',
          'unpublished'
        ).for(:status)
      end

      it 'do not allow enything else' do
        should_not allow_values(
          '', 'something-else'
        ).for(:status)
      end
    end

    context 'service_id' do
      it 'do not allow blank' do
        should_not allow_values('').for(:service_id)
      end
    end
  end

  describe '#completed?' do
    let(:publish_service) do
      create(:publish_service, :dev, :completed)
    end

    it 'returns true' do
      expect(publish_service.completed?).to be_truthy
    end
  end

  describe '#queued?' do
    let(:publish_service) do
      create(:publish_service, :dev, :queued)
    end

    it 'returns true' do
      expect(publish_service.queued?).to be_truthy
    end
  end

  describe '#unpublishing?' do
    let(:publish_service) do
      create(:publish_service, :dev, :unpublishing)
    end

    it 'returns true' do
      expect(publish_service.unpublishing?).to be_truthy
    end
  end

  describe '#unpublished?' do
    let(:publish_service) do
      create(:publish_service, :dev, :unpublished)
    end

    it 'returns true' do
      expect(publish_service.unpublished?).to be_truthy
    end
  end

  describe '#published?' do
    context 'when published' do
      let(:publish_service) do
        create(:publish_service, :dev, :completed)
      end

      it 'returns true' do
        expect(publish_service.published?).to be_truthy
      end
    end

    context 'when unpublishing' do
      let(:publish_service) do
        create(:publish_service, :dev, :unpublishing)
      end

      it 'returns false' do
        expect(publish_service.published?).to be_falsey
      end
    end

    context 'when unpublished' do
      let(:publish_service) do
        create(:publish_service, :dev, :unpublished)
      end

      it 'returns false' do
        expect(publish_service.published?).to be_falsey
      end
    end
  end
end
