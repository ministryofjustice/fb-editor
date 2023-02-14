RSpec.describe PublishServicePresenter do
  subject(:publish_service_presenter) do
    described_class.new(
      query, service
    )
  end
  let(:published_url) { 'https://version-fixture.dev.test.form.service.justice.gov.uk' }

  context 'when there is no published service' do
    let(:deployment_environment) { 'dev' }
    let(:query) do
      PublishService.where(
        service_id: service.service_id,
        deployment_environment:
      )
    end

    describe '#latest' do
      it 'returns nil' do
        expect(subject.latest).to be_nil
      end
    end

    describe '#published?' do
      it 'returns falsey' do
        expect(subject.published?).to be_falsey
      end
    end

    describe '#first_publish?' do
      it 'returns falsey' do
        expect(subject.first_publish?).to be_falsey
      end
    end

    describe '#url' do
      it 'returns falsey' do
        expect(subject.url).to be_falsey
      end
    end
  end

  context 'when there is a single published service' do
    let(:deployment_environment) { 'dev' }
    let!(:published_service) do
      create(:publish_service, :dev, :completed, service_id: service.service_id)
    end
    let(:query) do
      PublishService.where(
        service_id: service.service_id,
        deployment_environment:
      )
    end

    describe '#latest' do
      it 'returns the publish service' do
        expect(subject.latest).to eql published_service
      end
    end

    describe '#published?' do
      it 'returns truthy' do
        expect(subject.published?).to be_truthy
      end
    end

    describe '#first_publish?' do
      it 'returns truthy' do
        expect(subject.first_publish?).to be_truthy
      end
    end

    describe '#url' do
      it 'returns the url' do
        expect(subject.url).to eql published_url
      end
    end
  end

  context 'when there are multiple published services' do
    let(:deployment_environment) { 'dev' }
    let!(:prev_published_service) do
      create(:publish_service, :dev, :completed, service_id: service.service_id)
    end
    let!(:published_service) do
      create(:publish_service, :dev, :completed, service_id: service.service_id)
    end
    let(:query) do
      PublishService.where(
        service_id: service.service_id,
        deployment_environment:
      )
    end

    describe '#latest' do
      it 'returns the publish service' do
        expect(subject.latest).to eql published_service
      end
    end

    describe '#published?' do
      it 'returns truthy' do
        expect(subject.published?).to be_truthy
      end
    end

    describe '#first_publish?' do
      it 'returns falsey' do
        expect(subject.first_publish?).to be_falsey
      end
    end

    describe '#url' do
      it 'returns the url' do
        expect(subject.url).to eql published_url
      end
    end
  end

  context 'when the service is unpublished' do
    let(:deployment_environment) { 'dev' }
    let!(:unpublished_service) do
      create(:publish_service, :dev, :unpublished, service_id: service.service_id)
    end
    let(:query) do
      PublishService.where(
        service_id: service.service_id,
        deployment_environment:
      )
    end

    describe '#latest' do
      it 'returns publish_service' do
        expect(subject.latest).to eql unpublished_service
      end
    end

    describe '#published?' do
      it 'returns falsey' do
        expect(subject.published?).to be_falsey
      end
    end

    describe '#first_publish?' do
      it 'returns falsey' do
        expect(subject.first_publish?).to be_falsey
      end
    end

    describe '#url' do
      it 'returns falsey' do
        expect(subject.url).to be_falsey
      end
    end
  end

  context 'when the service has been republished' do
    let(:deployment_environment) { 'dev' }
    let!(:prev_unpublished_service) do
      create(:publish_service, :dev, :unpublished, service_id: service.service_id)
    end
    let!(:published_service) do
      create(:publish_service, :dev, :completed, service_id: service.service_id)
    end
    let(:query) do
      PublishService.where(
        service_id: service.service_id,
        deployment_environment:
      )
    end

    describe '#latest' do
      it 'returns the publish service' do
        expect(subject.latest).to eql published_service
      end
    end

    describe '#published?' do
      it 'returns truthy' do
        expect(subject.published?).to be_truthy
      end
    end

    describe '#first_publish?' do
      it 'returns truthy' do
        expect(subject.first_publish?).to be_truthy
      end
    end

    describe '#url' do
      it 'returns the url' do
        expect(subject.url).to eql published_url
      end
    end
  end

  context 'when there are publishes in different environments' do
    let(:deployment_environment) { 'dev' }
    let!(:published_service) do
      create(:publish_service, :dev, :completed, service_id: service.service_id)
    end
    let!(:prod_published_service) do
      create(:publish_service, :production, :completed, service_id: service.service_id)
    end
    let(:query) do
      PublishService.where(
        service_id: service.service_id,
        deployment_environment:
      )
    end

    describe '#latest' do
      it 'returns the publish service' do
        expect(subject.latest).to eql published_service
      end
    end
  end

  context 'when the publish is in progress' do
    let(:deployment_environment) { 'dev' }
    let!(:published_service) do
      create(:publish_service, :dev, :queued, service_id: service.service_id)
    end
    let(:query) do
      PublishService.where(
        service_id: service.service_id,
        deployment_environment:
      )
    end

    describe '#latest' do
      it 'returns the publish service' do
        expect(subject.latest).to eql published_service
      end
    end

    describe '#published?' do
      it 'returns truthy' do
        expect(subject.published?).to be_truthy
      end
    end

    describe '#first_publish?' do
      it 'returns truthy' do
        expect(subject.first_publish?).to be_truthy
      end
    end

    describe '#url' do
      it 'returns the url' do
        expect(subject.url).to eql published_url
      end
    end
  end
end
