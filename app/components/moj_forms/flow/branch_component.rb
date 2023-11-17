module MojForms
  module Flow
    class BranchComponent < MojForms::Flow::FlowItemComponent
      delegate :flow_branch_link, to: :helpers
    end
  end
end
