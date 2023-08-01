class ConditionalContentsController < FormController
  before_action :assign_conditional_content, only: %i[new]
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

  def new
    assign_conditional_content
  end

  def create
    @conditional_content = ConditionalContent.new(conditional_content_params)
  end

  def conditional_index
    params[:conditional_index] ? params[:conditional_index].to_i + 1 : nil
  end
  helper_method :conditional_index

  private

  def assign_conditional_content
    @conditional_content = ConditionalContent.new(conditional_content_attributes)
    @conditional_content.conditionals << ComponentConditional.new(expressions: [ComponentExpression.new])
  end

  def conditional_content_attributes
    {
      service:,
      previous_flow_uuid:,
      conditional_content_uuid: params[:conditional_content_uuid]
    }
  end

  def conditional_content_params
    params.require(:conditional_content).permit!.merge(conditional_content_attributes)
  end

  def previous_flow_uuid
    page_uuid = service.page_with_component(params[:conditional_content_component_id]).uuid
    previous_flow_obj = service.flow.select { |_k, v| v['next']['default'] == page_uuid }
    previous_flow_obj.keys.first
  end
end
