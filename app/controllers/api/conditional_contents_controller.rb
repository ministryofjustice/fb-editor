module Api
  class ConditionalContentsController < ApiController
    before_action :assign_conditional_content, only: %i[new_conditional]
    # skip_before_action :authorised_access
    default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

    def new
      assign_conditional_content
      render 'new', layout: false
    end

    def edit
      component = JSON.parse( params.require(:component), object_class: OpenStruct)

      if component.conditionals.present?
        @conditional_content = ConditionalContent.new(conditional_content_attributes.merge(ConditionalContent.from_metadata(component)))  
      else
        assign_conditional_content
      end

      render 'edit', layout: false
    end

    def update
      @conditional_content = ConditionalContent.new(conditional_content_params)

      if @conditional_content.valid? && !@conditional_content.any_errors?
        render json: { conditionals: @conditional_content.to_metadata }, status: :ok
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def conditional_index
      params[:conditional_index] ? params[:conditional_index].to_i + 1 : nil
    end
    helper_method :conditional_index

    def new_conditional
      # respond_to do |format|
      #   format.turbo_stream { render 'new_condition'}
      #   format.html { render 'new_conditional', layout: false }
      # end
      @conditional_content.conditionals << ComponentConditional.new(expressions: [ComponentExpression.new])
      render 'new_conditional', layout: false
    end

    def new_conditional_expression
      @conditional_component.conditionals[params[:conditional_index]].expressions << ComponentExpression.new
    end

    def require_user!
      unless user_signed_in?
        render json: { message: 'Unauthorised' }, status: :unauthorized
      end
    end

    private

    def assign_conditional_content
      @conditional_content = ConditionalContent.new(conditional_content_attributes.merge(ConditionalContent.from_metadata(component)))
      unless @conditional_content.conditionals.present?
        @conditional_content.conditionals << ComponentConditional.new(expressions: [ComponentExpression.new])
      end
    end

    def conditional_content_attributes
      {
        service:,
        previous_flow_uuid:,
        component_uuid: params[:component_uuid]
      }
    end

    def conditional_content_params
      params.require(:conditional_content).permit!.merge(conditional_content_attributes)
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
