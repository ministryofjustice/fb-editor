module Api
  class QuestionOptionsController < ApiController
    def destroy_message
      @page = service.find_page_by_uuid(params[:page_id])
      @question = @page.find_component_by_uuid(params[:question_id])
      @option = @question.find_item_by_uuid(params[:question_option_id])
      @label = @option.present? ? @option.name : params[:label]

      render DestroyQuestionOptionModal.new(
        service: service,
        page: @page,
        question: @question,
        option: @option,
        label: @label
      )
    end
  end
end
