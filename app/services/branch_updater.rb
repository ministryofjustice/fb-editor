class BranchUpdater < FlowBranch
  def flow_branch
    existing_metadata = service.flow[previous_flow_uuid]
    existing_metadata['next']['default'] = default_next
    existing_metadata['next']['conditionals'] = conditionals.map(&:to_metadata)

    OpenStruct.new(
      to_metadata: { previous_flow_uuid => existing_metadata },
      uuid: previous_flow_uuid
    )
  end
end
