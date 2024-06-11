RSpec.describe MsListWarningPresenter do
  let(:presenter) { described_class.new(service:, deployment_environment:) }
  let(:latest_metadata) { metadata_fixture(:branching) }
  let(:service) { MetadataPresenter::Service.new(latest_metadata) }
  let(:deployment_environment) { 'dev' }

  context 'on first publish' do
    before do
      expect(presenter).to receive(:first_publish?).and_return(true)
    end

    it "doesn't show a warning" do
      expect(presenter.message).to eq(nil)
    end
  end

  context 'when latest is nil' do
    before do
      expect(presenter).to receive(:first_publish?).and_return(false)
      expect(presenter).to receive(:latest).and_return(nil)
    end

    it "doesn't show a warning" do
      expect(presenter.message).to eq(nil)
    end
  end

  context 'when there is a published version and they do not match' do
    let!(:latest) do
      create(:publish_service, :dev, :completed, service_id: service.service_id)
    end
    before do
      expect(presenter).to receive(:first_publish?).and_return(false)
      allow(presenter).to receive(:latest).and_return(latest)
    end

    it "doesn't show a warning" do
      expect(presenter.message).to eq(I18n.t("warnings.publish.#{deployment_environment}.ms_list"))
    end
  end

  context 'when there is a published version and they do match' do
    let!(:latest) do
      create(:publish_service, :dev, :completed, service_id: service.service_id, version_id: service.version_id)
    end
    before do
      expect(presenter).to receive(:first_publish?).and_return(false)
      allow(presenter).to receive(:latest).and_return(latest)
    end

    it "doesn't show a warning" do
      expect(presenter.message).to eq(nil)
    end
  end
end
