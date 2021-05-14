module Api
  class PagesController < ApiController
    def show
      render json: {
        meta: {
          default_text: I18n.t('default_text')
        }
      }
    end
  end
end
