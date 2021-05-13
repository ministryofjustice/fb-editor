module Api
  class PagesController < ApiController
    def show
      render json: {
        meta: {
          default_text: Rails.application.config.default_text
        }
      }
    end
  end
end
