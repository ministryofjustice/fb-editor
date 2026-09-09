module Api
  class ConditionalContentsController < ApiController
    default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

    def edit
      @conditional_content = ConditionalContent.new(conditional_content_attributes.merge(ConditionalContent.from_json(component_params)))

      if @conditional_content.conditionals.blank?
        @conditional_content.conditionals << ComponentConditional.new(expressions: [ComponentExpression.new(service:)])
      end

      render 'edit', layout: false
    end

    def update
      @conditional_content = ConditionalContent.new(conditional_content_params)

      if @conditional_content.valid? && !@conditional_content.any_errors?
        render json: @conditional_content.to_metadata, status: :ok
      else
        render 'edit', layout: false, status: :unprocessable_entity
      end
    end

    def conditional_index
      params[:conditional_index] ? params[:conditional_index].to_i + 1 : nil
    end
    helper_method :conditional_index

    def new_conditional_expression
      @conditional_component.conditionals[params[:conditional_index]].expressions << ComponentExpression.new(service:)
    end

    def require_user!
      unless user_signed_in?
        render json: { message: 'Unauthorised' }, status: :unauthorized
      end
    end

    private

    def conditional_content_attributes
      {
        service:,
        previous_flow_uuid:,
        component_uuid: params[:component_uuid]
      }
    end

    def conditional_content_params
      params.require(:conditional_content).permit(:previous_flow_uuid, :component_uuid, :display, conditionals_attributes: {}).merge(conditional_content_attributes)
    end

    def component_params
      params.require(:component)
    end

    def previous_flow_uuid
      if params[:component_uuid].present?
        page_uuid = service.page_with_component(params[:component_uuid]).uuid
        previous_flow_obj = service.flow.select { |_k, v| v['next']['default'] == page_uuid }
        return previous_flow_obj.keys.first
      end

      params['conditional_content']['previous_flow_uuid']
    end

    def page
      @page ||= service.page_with_component(params[:component_uuid])
    end

    def component
      @component = page.find_component_by_uuid(params[:component_uuid])
    end
  end
end
