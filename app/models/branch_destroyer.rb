class BranchDestroyer
  include ActiveModel::Model
  include PreviousPageTitle
  include ApplicationHelper
  attr_accessor :service, :branch_uuid, :latest_metadata
  attr_writer :destination_uuid

  delegate :branches, to: :service
  delegate :title, to: :flow

  def destination_uuid
    @destination_uuid || destinations.first.try(:uuid) # Always the first selected
  end

  def destinations
    flow.all_destination_uuids.map do |uuid|
      service.find_page_by_uuid(uuid)
    end
  end

  def destroy
    MetadataApiClient::Version.create(
      service_id: service.service_id,
      payload: destroyed_branch_metadata
    )
  end

  def destroyed_branch_metadata
    metadata = latest_metadata.to_h.deep_dup

    metadata.tap do
      metadata['flow'].each_value do |flow_hash|
        if flow_hash['next'] && flow_hash['next']['default'] == branch_uuid
          flow_hash['next']['default'] = destination_uuid
        end
      end

      metadata['flow'].delete(branch_uuid)
    end
  end

  private

  def flow
    service.flow_object(branch_uuid)
  end
end
