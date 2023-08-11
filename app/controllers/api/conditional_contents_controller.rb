class Api::ConditionalContentsController < ConditionalContentsController
  before_action :assign_conditional_content, only: %i[new_conditional]
  skip_before_action :authorised_access

  def new_conditional
    render 'new_conditional', layout: false
  end

  def require_user!
    unless user_signed_in?
      render json: { message: 'Unauthorised' }, status: :unauthorized
    end
  end
end
