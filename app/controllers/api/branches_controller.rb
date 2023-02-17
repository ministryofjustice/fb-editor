class Api::BranchesController < BranchesController
  before_action :assign_branch, only: %i[new_conditional]
  skip_before_action :authorised_access

  def new_conditional
    render layout: false
  end

  def destroy_message
    @branch = BranchDestroyer.new(
      service:,
      branch_uuid: params[:branch_previous_flow_uuid]
    )

    render layout: false
  end

  def require_user!
    unless user_signed_in?
      render json: { message: 'Unauthorised' }, status: :unauthorized
    end
  end
end
