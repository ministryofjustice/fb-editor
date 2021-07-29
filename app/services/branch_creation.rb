class BranchCreation < FlowBranch
  def update_previous_page
    latest_metadata['flow'][previous_flow_uuid]['next']['default'] = branch_uuid
  end

  def flow_branch
    @flow_branch ||= NewFlowBranchGenerator.new(
      default_next: default_next,
      conditionals: conditionals
    )
  end
end
