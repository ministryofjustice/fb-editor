class BranchCreation
  include ActiveModel::Model
  delegate :previous_flow_uuid, :version, :service, :conditionals,
           :default_next, to: :branch

  attr_accessor :branch, :latest_metadata

  def create
    return false if branch.invalid?

    version = MetadataApiClient::Version.create(
      service_id: service.service_id,
      payload: metadata
    )

    if version.errors?
      errors.add(:base, :invalid, message: version.errors)
      false
    else
      @version = version
    end
  end

  def branch_uuid
    new_branch.uuid
  end

  def metadata
    latest_metadata['flow'].merge!(new_branch.to_metadata)
    latest_metadata['flow'][previous_flow_uuid]['next']['default'] = branch_uuid
    latest_metadata
  end

  private

  def new_branch
    @new_branch ||= NewFlowBranchGenerator.new(
      default_next: default_next,
      conditionals: conditionals
    )
  end
end
