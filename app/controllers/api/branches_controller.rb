class Api::BranchesController < BranchesController
  before_action :assign_branch, only: %i[new_conditional]

  def new_conditional
    render layout: false
  end
end
