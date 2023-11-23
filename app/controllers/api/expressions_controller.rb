module Api
  class ExpressionsController < BranchesController
    rescue_from(ArgumentError) do |_exception|
      render json: { message: 'unprocessable entity' }, status: :unprocessable_entity
    end
    before_action :validate_params

    def show
      @expression = Expression.new(
        component: params[:component_uuid],
        page: page_with_component
      )

      render partial: 'expression_condition',
             locals: {
               f: default_form_builder.new(:expression, @expression, view_context, {}),
               expression: @expression,
               conditional_index: params[:conditional_index],
               expression_index: params[:expression_index]
             }
    end

    def page_with_component
      service.page_with_component(params[:component_uuid])
    end

    def validate_params
      Integer(params[:conditional_index]) &&
        Integer(params[:expression_index])
    end
  end
end
