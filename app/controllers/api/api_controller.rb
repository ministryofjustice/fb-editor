module Api
  class ApiController < ActionController::API
    include Auth0Helper
    include ActionView::Layouts
    include ActionController::Rendering
    before_action :require_user!

    def require_user!
      unless user_signed_in?
        render json: { message: 'Unauthorised' }, status: :unauthorized
      end
    end
  end
end
