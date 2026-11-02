require 'rails_helper'

RSpec.describe Export::S3::Form::MetadataSource do
  subject(:metadata_source) { described_class.new(per_page: per_page) }

  let(:per_page) { 2 }
  let(:service_1) do
    double(
      id: 'service-1',
      name: 'Service One',
      metadata: {
        'items' => [{ 'id' => 'item-1' }],
        'metadata' => [
          {
            'id' => 'v1',
            'service_id' => 'service-1',
            'data' => { 'title' => 'Form 1' },
            'created_at' => '2026-01-01T00:00:00Z',
            'locale' => 'en'
          }
        ]
      }
    )
  end
  let(:service_2) do
    double(
      id: 'service-2',
      name: 'Service Two',
      metadata: {
        'items' => [],
        'metadata' => []
      }
    )
  end
  let(:setting_1) { double(service_id: 'service-1', name: 'SETTING_A') }

  before do
    allow(ServiceConfiguration).to receive(:where).with(service_id: %w[service-1 service-2]).and_return([setting_1])
  end

  describe '#each_service_version' do
    context 'without a block' do
      it 'returns an Enumerator' do
        expect(metadata_source.each_service_version).to be_an(Enumerator)
      end
    end

    context 'with a block' do
      before do
        allow(MetadataApiClient::Service).to receive(:all_services).with(page: 1, per_page: 2, include: 'metadata').and_return(
          { services: [service_1, service_2] }
        )
        allow(MetadataApiClient::Service).to receive(:all_services).with(page: 2, per_page: 2, include: 'metadata').and_return(
          { services: [] }
        )
      end

      it 'yields ServiceEntry for each service with settings and versions' do
        entries = []
        metadata_source.each_service_version { |entry| entries << entry }

        expect(entries.size).to eq(2)

        entry_1 = entries.first
        expect(entry_1.service_id).to eq('service-1')
        expect(entry_1.service_name).to eq('Service One')
        expect(entry_1.settings).to eq([setting_1])
        expect(entry_1.items).to eq([{ 'id' => 'item-1' }])
        expect(entry_1.versions.size).to eq(1)

        version = entry_1.versions.first
        expect(version.version_id).to eq('v1')
        expect(version.service_id).to eq('service-1')
        expect(version.metadata).to eq({ 'title' => 'Form 1' })
        expect(version.created_at).to eq('2026-01-01T00:00:00Z')
        expect(version.locale).to eq('en')

        entry_2 = entries.second
        expect(entry_2.service_id).to eq('service-2')
        expect(entry_2.service_name).to eq('Service Two')
        expect(entry_2.settings).to eq([])
        expect(entry_2.items).to eq([])
        expect(entry_2.versions).to eq([])
      end

      it 'paginates through all pages until an empty page is returned' do
        expect(MetadataApiClient::Service).to receive(:all_services).with(page: 1, per_page: 2, include: 'metadata').once
        expect(MetadataApiClient::Service).to receive(:all_services).with(page: 2, per_page: 2, include: 'metadata').once

        metadata_source.each_service_version.to_a
      end
    end

    context 'when service metadata is nil' do
      let(:service_empty_metadata) { double(id: 'service-nil', name: 'Empty', metadata: nil) }

      before do
        allow(MetadataApiClient::Service).to receive(:all_services).with(page: 1, per_page: 2, include: 'metadata').and_return(
          { services: [service_empty_metadata] }
        )
        allow(MetadataApiClient::Service).to receive(:all_services).with(page: 2, per_page: 2, include: 'metadata').and_return(
          { services: [] }
        )
        allow(ServiceConfiguration).to receive(:where).with(service_id: %w[service-nil]).and_return([])
      end

      it 'handles nil metadata gracefully' do
        entry = metadata_source.each_service_version.first
        expect(entry.service_id).to eq('service-nil')
        expect(entry.items).to eq([])
        expect(entry.versions).to eq([])
      end
    end
  end
end
