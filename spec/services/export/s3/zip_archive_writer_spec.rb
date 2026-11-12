require 'rails_helper'
require 'zip'

RSpec.describe Export::S3::ZipArchiveWriter do
  subject(:writer) { described_class.new }

  let(:tempfile) { Tempfile.new(['test_archive', '.zip']) }
  let(:zip_path) { tempfile.path }

  after do
    tempfile.close
    tempfile.unlink
  end

  describe '#write' do
    context 'when services list is empty' do
      it 'raises EmptyArchiveError' do
        expect {
          writer.write(zip_path, [])
        }.to raise_error(Export::S3::ZipArchiveWriter::EmptyArchiveError, 'No version metadata files were generated')
      end
    end

    context 'when services are present' do
      let(:setting_record) do
        double(as_json: { 'name' => 'SERVICE_NAME', 'value' => 'Test Service' })
      end

      let(:version_1) do
        Export::S3::MetadataSource::VersionEntry.new(
          version_id: 'v1',
          service_id: 'service-1',
          metadata: { 'title' => 'Form 1' },
          created_at: '2026-11-02T12:00:00Z',
          locale: 'en'
        )
      end

      let(:version_2) do
        Export::S3::MetadataSource::VersionEntry.new(
          version_id: 'v2/invalid:id',
          service_id: 'service-1',
          metadata: { 'title' => 'Form 2' },
          created_at: '2026-11-03T14:30:00Z',
          locale: 'cy'
        )
      end

      let(:service_entry) do
        Export::S3::MetadataSource::ServiceEntry.new(
          service_id: 'service/1',
          service_name: 'Test Service',
          settings: [setting_record],
          items: [{ 'id' => 'item-1' }],
          versions: [version_1, version_2]
        )
      end

      it 'creates a zip archive containing service.json, settings.json, items.json and version files' do
        result = writer.write(zip_path, [service_entry])
        expect(result).to eq(zip_path)

        Zip::File.open(zip_path) do |zip|
          entries = zip.entries.map(&:name)
          expect(entries).to contain_exactly(
            'service_1/service.json',
            'service_1/settings.json',
            'service_1/items.json',
            'service_1/version_20261102T120000_en_v1.json',
            'service_1/version_20261103T143000_cy_v2_invalid_id.json'
          )

          service_content = JSON.parse(zip.read('service_1/service.json'))
          expect(service_content).to eq({ 'service_id' => 'service/1', 'service_name' => 'Test Service' })

          settings_content = JSON.parse(zip.read('service_1/settings.json'))
          expect(settings_content).to eq([{ 'name' => 'SERVICE_NAME', 'value' => 'Test Service' }])

          items_content = JSON.parse(zip.read('service_1/items.json'))
          expect(items_content).to eq([{ 'id' => 'item-1' }])

          version_1_content = JSON.parse(zip.read('service_1/version_20261102T120000_en_v1.json'))
          expect(version_1_content).to eq({ 'title' => 'Form 1' })
        end
      end

      it 'handles services without optional settings, items, or versions' do
        minimal_service = Export::S3::MetadataSource::ServiceEntry.new(
          service_id: 'min-service',
          service_name: 'Minimal Service',
          settings: nil,
          items: nil,
          versions: nil
        )

        writer.write(zip_path, [minimal_service])

        Zip::File.open(zip_path) do |zip|
          entries = zip.entries.map(&:name)
          expect(entries).to contain_exactly('min-service/service.json')
        end
      end
    end
  end
end
