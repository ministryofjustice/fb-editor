module Admin
  class ApiSubmissionController < Admin::ApplicationController
    attr_reader :endpoint_url, :endpoint_key, :service_id, :deployment_environment

    def initialize
      @api_submission = Admin::ApiSubmission.new
      super
    end

    def set_api_submission_configuration
      @api_submission.service_id(params[:service_id])
      @api_submission.endpoint_url(params[:admin_api_submission][:saved_endpoint_url])
      @api_submission.endpoint_key(params[:admin_api_submission][:saved_endpoint_key])
    end

    def index
      # we save the service field to be send as hidden field
      @service_id = params[:service_id]
      @api_submission.service_id(params[:service_id])
      render 'index'
    end

    def create
      set_api_submission_configuration
      # render 'admin/services/show', object: @service
      @api_submission.create_service_configurations
      flash[:success] = "API submission settings successfully updated"
      render 'index'
    end

    def delete
      Rails.logger.debug 'We have to delete'
      # @api_submission.delete_service_configurations
    end
  end
end
