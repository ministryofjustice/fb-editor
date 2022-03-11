module Api
  class OptionsController < ApiController
    
    def destroy_message
      @page = service.find_page_by_uuid(params[:page_id])
      @question = @page.find_component_by_uuid(params[:question_id])
      @option = @question.find_item_by_uuid(params[:option_id])
      @label = @option ? @option.name : params[:label]

      render DestroyOptionModal.new(
        service: service,
        page: @page,
        question: @question,
        option: @option,
        label: @label, 
      )
    end
  end
end
