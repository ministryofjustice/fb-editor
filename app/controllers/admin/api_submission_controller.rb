module Admin
  class ApiSubmissionController < Admin::ApplicationController
    attr_reader :endpoint_url, :endpoint_key, :service_id, :deployment_environment

    def initialize
      settings = { service_id:, deployment_environment: }
      @api_submission = Admin::ApiSubmission.new(settings)
      super
    end

    def set_api_submission_configuration
      @api_submission.service_id(params[:service_id])
      @api_submission.endpoint_url(params[:admin_api_submission][:endpoint_url])
      @api_submission.endpoint_key(params[:admin_api_submission][:endpoint_key])
    end

    def index
      Rails.logger.debug 'We index'
      @api_submission.service_id(params[:service_id])
      render 'index'
    end

    def create
      Rails.logger.debug 'We create'
      set_api_submission_configuration
      # render 'admin/services/show', object: @service
      @api_submission.create_service_configurations
      render 'index'
    end

    # def show
    #   Rails.logger.debug 'We show'
    #   set_api_submission_configuration
    #   @endpoint_url = 'saved value 1'
    #   @endpoint_key = 'saved value 2'
    # end

    # def update
    #   Rails.logger.debug 'We update'
    #   @endpoint_url = params[:endpoint_url]
    #   @endpoint_key = params[:endpoint_key]
    #   # render 'admin/services/show', id: params[:service_id]
    #   render 'admin/services/show'
    # end

    def delete
      Rails.logger.debug 'We have to delete'
      # @api_submission.delete_service_configurations
    end
  end
end
