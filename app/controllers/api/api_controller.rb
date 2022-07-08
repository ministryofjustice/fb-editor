module Api
  class ApiController < ApplicationController
    include Auth0Helper
    before_action :require_user!

    def require_user!
      unless user_signed_in?
        render json: { message: 'Unauthorised' }, status: :unauthorized
      end
    end

    def items_present?
      ActiveModel::Type::Boolean.new.cast(params[:items_present])
    end
    helper_method :items_present?
  end
end
