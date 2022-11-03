RSpec.describe Publisher::Utils::ServiceMetadataFiles do
  subject(:service_metadata_files) do
    described_class.new(service_provisioner, adapter)
  end
  let(:service_id) { SecureRandom.uuid }
  let(:service_metadata) { '{}' }
  let(:autocomplete_items) { '{}' }
  let(:service_provisioner) do
    double(
      service_id: service_id,
      service_metadata: service_metadata,
      autocomplete_items: autocomplete_items
    )
  end
  let(:adapter) { double }

  context 'uploading service metadata files' do
    it 'uploads the service metadata and autocomplete items files' do
      expect(adapter).to receive(:upload).with(
        "#{service_id}_metadata.json",
        service_metadata
      ).once
      expect(adapter).to receive(:upload).with(
        "#{service_id}_autocomplete_items.json",
        autocomplete_items
      ).once
      service_metadata_files.upload
    end
  end
end
