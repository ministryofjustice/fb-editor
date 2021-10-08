module Api
  class QuestionsController < ApiController
    def destroy_message
      @page = service.find_page_by_uuid(params[:page_id])
      @question = @page.find_component_by_uuid(params[:question_id])

      render DestroyQuestionModal.new(
        service: service,
        page: @page,
        question: @question
      )
    end
  end
end
