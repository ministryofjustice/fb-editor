module Api
  class ConditionalContentExpressionsController < ConditionalContentsController
    rescue_from(ArgumentError) do |_exception|
      render json: { message: 'unprocessable entity' }, status: :unprocessable_entity
    end
    before_action :validate_params

    def show
      question_uuid = params["conditional_content"].dig("conditionals_attributes", params["conditional_index"], "expressions_attributes", params["expression_index"], "component")

        @expression = Expression.new(
          component: question_uuid,
          page: page_with_component(question_uuid)
        )

        render partial: 'expression_answers',
               locals: {
                 f: default_form_builder.new(:expression, @expression, view_context, {}),
                 expression: @expression,
                 conditional_index: params[:conditional_index],
                 expression_index: params[:expression_index]
               }

    end

    def page_with_component(uuid)
      service.page_with_component(uuid)
    end

    def validate_params
      Integer(params[:conditional_index]) &&
        Integer(params[:expression_index])
    end
  end
end
