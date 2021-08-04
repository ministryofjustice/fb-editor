class FlowBranch
  include MetadataVersion
  include ActiveModel::Model
  delegate :previous_flow_uuid, :version, :service, :conditionals,
           :default_next, to: :branch

  attr_accessor :branch, :latest_metadata

  def save
    return false if branch.invalid?

    create_version
  end

  def branch_uuid
    flow_branch.uuid
  end

  def metadata
    flow_branch_metadata = flow_branch.to_metadata
    latest_metadata['flow'].merge!(flow_branch_metadata)
    update_previous_page
    latest_metadata
  end

  # Method signature to be implemented on the subclass if needed.
  #
  def update_previous_page; end
end
