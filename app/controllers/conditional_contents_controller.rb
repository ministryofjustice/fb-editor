class ConditionalContentsController < FormController
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder
  before_action :assign_conditional_content, only: %i[new]

  def new; end

  private

  def assign_conditional_content
    @conditional_content = ConditionalContent.new(conditional_content_attributes)
    @conditional_content.conditionals << ComponentConditional.new(expressions:[ComponentExpression.new])
  end

  def conditional_content_attributes
    {
      service:,
      previous_flow_uuid:,
      component_id: params[:component_id]
    }
  end

  def previous_flow_uuid
    byebug
  end
end
