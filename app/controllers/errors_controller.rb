class ErrorsController < ActionController::Base
  def error_422
    byebug
    render status: :unprocessable_entity
  end
end
