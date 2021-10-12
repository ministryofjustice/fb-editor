class BranchDestroyer
  include ActiveModel::Model
  include PreviousPageTitle
  include ApplicationHelper
  attr_accessor :service, :branch_uuid

  delegate :branches, to: :service
  delegate :title, to: :flow

  def destinations
    flow.all_destination_uuids.map do |uuid|
      service.find_page_by_uuid(uuid)
    end
  end

  private

  def flow
    service.flow_object(branch_uuid)
  end
end
