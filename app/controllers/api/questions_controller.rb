module Api
  class QuestionsController < ApiController
    def destroy_message
      @page = service.find_page_by_uuid(params[:page_id])
      @question = @page.find_component_by_uuid(params[:question_id])
      @option = @question.find_item_by_uuid(params[:option_id])

      modal = DestroyQuestionModal.new(
        service:,
        page: @page,
        question: @question
      )
      render modal, locals: { pages: modal.pages }
    end
  end
end
