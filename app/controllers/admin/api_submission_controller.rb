module Admin
  class ApiSubmissionController < Admin::ApplicationController
    attr_reader :service_id

    def initialize
      @api_submission = Admin::ApiSubmission.new
      super
    end

    def index
      # we save the service field to be send as hidden field
      @service_id = params[:service_id]
      @api_submission.service_id(params[:service_id])
      render 'index'
    end

    def create
      url = params[:admin_api_submission][:saved_endpoint_url]
      key = params[:admin_api_submission][:saved_endpoint_key]
      @api_submission.service_id(params[:service_id])
      @api_submission.endpoint_url(url)
      @api_submission.endpoint_key(key)
      if url.blank? || key.blank?
        flash[:error] = 'Please use the delete button to delete API settings'
      else
        @api_submission.create_service_configurations
        flash[:success] = 'API submission settings successfully updated'
      end
      # render 'admin/services/show', object: @service
      render 'index'
    end

    def delete
      Rails.logger.debug 'We have to delete'
      # @api_submission.delete_service_configurations
    end
  end
end
