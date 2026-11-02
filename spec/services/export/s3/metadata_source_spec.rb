# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Export::S3::MetadataSource, type: :service do
  subject(:source) do
    described_class.new(
      per_page: per_page,
      query: query
    )
  end

  let(:per_page) { 2 }
  let(:query) { 'test-query' }
  let(:service_api) { MetadataApiClient::Service }
  let(:version_api) { MetadataApiClient::Version }

  describe '#each_service_version' do
    context 'when called without a block' do
      it 'returns an Enumerator' do
        expect(source.each_service_version).to be_an(Enumerator)
      end
    end

    context 'when iterating through services and versions' do
      let(:service1_id) { SecureRandom.uuid }
      let(:service2_id) { SecureRandom.uuid }
      let(:service3_id) { SecureRandom.uuid }

      let(:service1_obj) { double('Service1', id: service1_id) }
      let(:service2_hash) { { 'id' => service2_id } }
      let(:service3_hash_sym) { { id: service3_id } }
      let(:service_invalid) { double('ServiceInvalid', id: nil) }

      let(:version1_summary) { double('Version1Summary', metadata: { 'version_id' => 'v1' }) }
      let(:version2_summary) { { metadata: { version_id: 'v2' } } }
      let(:version_invalid_summary) { { metadata: nil } }

      let(:version1_detail) { double('Version1Detail', metadata: { 'service_name' => 'Service 1' }, created_at: '2026-11-01 10:00:00 UTC') }
      let(:version2_detail) { double('Version2Detail', metadata: nil, created_at: '2026-11-01 11:00:00 UTC') }

      let!(:service1_config) do
        create(
          :service_configuration,
          :dev,
          :username,
          service_id: service1_id
        )
      end

      before do
        # Page 1: returns service1_obj, service2_hash
        allow(service_api).to receive(:all_services)
          .with(page: 1, per_page: per_page, query: query)
          .and_return({ services: [service1_obj, service2_hash], total_services: 4 })

        # Page 2: returns service3_hash_sym, service_invalid
        allow(service_api).to receive(:all_services)
          .with(page: 2, per_page: per_page, query: query)
          .and_return({ services: [service3_hash_sym, service_invalid], total_services: 4 })

        # Page 3: not called because seen == 4 >= total_services

        # Service 1 versions
        allow(version_api).to receive(:all).with(service1_id).and_return([version1_summary, version2_summary, version_invalid_summary])
        allow(version_api).to receive(:find).with(service_id: service1_id, version_id: 'v1').and_return(version1_detail)
        allow(version_api).to receive(:find).with(service_id: service1_id, version_id: 'v2').and_return(version2_detail)

        # Service 2 & 3 versions
        allow(version_api).to receive(:all).with(service2_id).and_return([])
        allow(version_api).to receive(:all).with(service3_id).and_return([])
      end

      it 'paginates through all services and yields ServiceEntry objects with filtered versions and settings' do
        yielded_entries = []
        source.each_service_version { |entry| yielded_entries << entry }

        expect(yielded_entries.size).to eq(3)

        entry1 = yielded_entries[0]
        expect(entry1).to be_a(Export::S3::MetadataSource::ServiceEntry)
        expect(entry1.service_id).to eq(service1_id)
        expect(entry1.settings).to include(service1_config)
        expect(entry1.versions.size).to eq(1)

        v1_entry = entry1.versions.first
        expect(v1_entry).to be_a(Export::S3::MetadataSource::VersionEntry)
        expect(v1_entry.version_id).to eq('v1')
        expect(v1_entry.metadata).to eq({ 'service_name' => 'Service 1' })
        expect(v1_entry.created_at).to eq('2026-11-01 10:00:00 UTC')

        entry2 = yielded_entries[1]
        expect(entry2.service_id).to eq(service2_id)
        expect(entry2.settings).to be_empty
        expect(entry2.versions).to be_empty

        entry3 = yielded_entries[2]
        expect(entry3.service_id).to eq(service3_id)
        expect(entry3.settings).to be_empty
        expect(entry3.versions).to be_empty
      end
    end

    context 'when API returns empty services list' do
      before do
        allow(service_api).to receive(:all_services)
          .with(page: 1, per_page: per_page, query: query)
          .and_return({ services: [], total_services: 0 })
      end

      it 'yields nothing' do
        expect { |b| source.each_service_version(&b) }.not_to yield_control
      end
    end
  end
end
