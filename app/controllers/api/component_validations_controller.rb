module Api
  class ComponentValidationsController < ApiController
    before_action :assign_component_validation

    def new
      render @component_validation, layout: false
    end

    def create
      if @component_validation.valid?
        render json: @component_validation.to_metadata, status: :accepted
      else
        render @component_validation, layout: false, status: :unprocessable_entity
      end
    end

    private

    def assign_component_validation
      # puts "-------> base_params #{base_params}, validation_params: #{validation_params}"
      @component_validation = BaseComponentValidation.new(base_params).assign_validation(validation_params)
    end

    def validation_params
      return base_params if action_name == 'new'

      component_validation_params
    end

    def base_params
      @base_params ||=
        {
          service:,
          page_uuid: params[:page_id],
          component_uuid: params[:component_id],
          validator: params[:validator]
        }
    end

    def component_validation_params
      params.require(:component_validation)
            .permit(:status, :value, :day, :month, :year, :string_length)
            .merge(base_params)
            .compact
    end
  end
end
