module Api
  class ExpressionsController < BranchesController
    rescue_from(ArgumentError) do |exception|
      render json: { message: 'unprocessable entity' }, status: :unprocessable_entity
    end
    before_action :validate_params

    def show
      @expression = Expression.new(
        component: params[:component_id],
        page: page_with_component
      )

      render partial: 'expression_answers',
             locals: {
               f: default_form_builder.new(:expression, @expression, view_context, {}),
               conditional_index: params[:conditional_index],
               expression_index: params[:expression_index]
             }
    end

    def page_with_component
      @page_with_component ||= service.page_with_component(params[:component_id])
    end

    def component
      page_with_component.find_component_by_uuid(params[:component_id])
    end

    def component_type
      component.type
    end
    helper_method :component_type

    def expression_name(attribute)
      "branch[conditionals_attributes][#{params[:conditional_index]}]" \
      "[expressions_attributes][#{params[:expression_index]}][#{attribute}]"
    end
    helper_method :expression_name

    def expression_id(attribute)
      "branch_conditionals_attributes_#{params[:conditional_index]}_" \
      "expressions_attributes_#{params[:expression_index]}_#{attribute}"
    end
    helper_method :expression_id

    def validate_params
      Integer(params[:conditional_index]) &&
        Integer(params[:expression_index])
    end
  end
end
