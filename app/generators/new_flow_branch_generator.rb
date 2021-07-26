class NewFlowBranchGenerator
  include ActiveModel::Model
  attr_accessor :default_next, :conditionals

  def to_metadata
    metadata = DefaultMetadata['flow.branch']
    metadata['next']['default'] = default_next
    metadata['next']['conditionals'] = conditionals.map(&:to_metadata)

    { uuid => metadata }
  end

  def uuid
    @uuid ||= SecureRandom.uuid
  end
end
