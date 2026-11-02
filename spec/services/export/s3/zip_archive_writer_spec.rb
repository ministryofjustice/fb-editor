# frozen_string_literal: true

require 'rails_helper'
require 'zip'

RSpec.describe Export::S3::ZipArchiveWriter, type: :service do
  subject(:writer) { described_class.new }

  let(:tmp_dir) { Dir.mktmpdir('zip_archive_writer_spec') }
  let(:zip_path) { File.join(tmp_dir, 'output.zip') }

  after do
    FileUtils.remove_entry(tmp_dir) if File.exist?(tmp_dir)
  end

  describe '#write' do
    context 'when given valid services' do
      let(:setting_record) do
        double(
          'ServiceConfiguration',
          as_json: { 'name' => 'SERVICE_NAME', 'value' => 'My Form' }
        )
      end
      let(:settings) { [setting_record] }

      let(:version1) do
        Export::S3::MetadataSource::VersionEntry.new(
          version_id: 'version-1',
          metadata: { 'service_name' => 'My Form', 'pages' => [] },
          created_at: '2026-11-02 12:00:00 UTC'
        )
      end

      let(:version2) do
        Export::S3::MetadataSource::VersionEntry.new(
          version_id: 'version:2/unsafe',
          metadata: { 'service_name' => 'My Form v2', 'pages' => [] },
          created_at: '2026-11-03 15:30:00 +0000'
        )
      end

      let(:service1) do
        Export::S3::MetadataSource::ServiceEntry.new(
          service_id: 'service-abc-123',
          settings: settings,
          versions: [version1, version2]
        )
      end

      let(:service2) do
        Export::S3::MetadataSource::ServiceEntry.new(
          service_id: 'service/xyz:456',
          settings: [],
          versions: []
        )
      end

      let(:services) { [service1, service2] }

      it 'returns the zip_path' do
        expect(writer.write(zip_path, services)).to eq(zip_path)
      end

      it 'creates a valid zip file with expected entries and content' do
        writer.write(zip_path, services)

        expect(File.exist?(zip_path)).to be(true)

        Zip::File.open(zip_path) do |zip|
          entry_names = zip.map(&:name)

          expect(entry_names).to contain_exactly(
            'service-abc-123/settings.json',
            'service-abc-123/version-1_20261102T120000Z_metadata.json',
            'service-abc-123/version_2_unsafe_20261103T153000Z_metadata.json',
            'service_xyz_456/settings.json'
          )

          settings_content = zip.find_entry('service-abc-123/settings.json').get_input_stream.read
          expect(JSON.parse(settings_content)).to eq([{ 'name' => 'SERVICE_NAME', 'value' => 'My Form' }])

          v1_content = zip.find_entry('service-abc-123/version-1_20261102T120000Z_metadata.json').get_input_stream.read
          expect(JSON.parse(v1_content)).to eq({ 'service_name' => 'My Form', 'pages' => [] })

          v2_content = zip.find_entry('service-abc-123/version_2_unsafe_20261103T153000Z_metadata.json').get_input_stream.read
          expect(JSON.parse(v2_content)).to eq({ 'service_name' => 'My Form v2', 'pages' => [] })
        end
      end
    end

    context 'when services collection is empty' do
      let(:services) { [] }

      it 'raises EmptyArchiveError' do
        expect {
          writer.write(zip_path, services)
        }.to raise_error(Export::S3::ZipArchiveWriter::EmptyArchiveError, 'No version metadata files were generated')
      end
    end
  end
end
