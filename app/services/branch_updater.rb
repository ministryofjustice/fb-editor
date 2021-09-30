class BranchUpdater < FlowBranch
  def flow_branch
    existing_metadata = service.flow[branch.branch_uuid]
    existing_metadata['next']['default'] = default_next
    existing_metadata['next']['conditionals'] = conditionals.map(&:to_metadata)

    OpenStruct.new(
      to_metadata: { branch.branch_uuid => existing_metadata },
      uuid: branch.branch_uuid
    )
  end
end
