class BranchCreation < FlowBranch
  def before_create(flow_branch_metadata)
    flow_branch_metadata[flow_branch.uuid]['title'] = title
  end

  def after_create
    latest_metadata['flow'][previous_flow_uuid]['next']['default'] = branch_uuid
  end

  def flow_branch
    @flow_branch ||= NewFlowBranchGenerator.new(
      default_next:,
      conditionals:
    )
  end
end
