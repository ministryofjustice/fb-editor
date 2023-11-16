module MojForms
  module FlowItems
    class BranchComponent < MojForms::FlowItemComponent
      delegate :flow_branch_link, to: :helpers
    end
  end
end
