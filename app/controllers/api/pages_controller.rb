module Api
  class PagesController < ApiController
    def show
      render json: {
        meta: {
          default_text: I18n.t('default_text')
        }
      }
    end

    def destroy_message
      @page = service.find_page_by_uuid(params[:page_id])
      
      modal =  DestroyPageModal.new(service:, page: @page)
      render modal, locals: { pages: modal.pages }
    end
  end
end
