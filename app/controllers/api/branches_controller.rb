class Api::BranchesController < BranchesController
  before_action :assign_branch, only: %i[new_conditional]
  skip_before_action :authorised_access

  def new_conditional
    render layout: false
  end

  def destroy_message
    @branch = BranchDestroyer.new(
      service: service,
      branch_uuid: params[:branch_previous_flow_uuid]
    )

    render layout: false
  end
end
