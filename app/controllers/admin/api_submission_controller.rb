module Admin
  class ApiSubmissionController < Admin::ApplicationController
    attr_reader :api_json_endpoint_url, :api_json_endpoint_key, :service_id

    def initialize
      @api_submission = ApiSubmission.new
    end

    def index
      @service_id = params[:service_id]
      render 'index'
    end

    def create
      # create service configuration
      @service_id = params[:service_id]
      @api_json_endpoint_url = params[:api_json_endpoint_url]
      @api_json_endpoint_url = params[:api_json_endpoint_key]
      # render 'admin/services/show', object: @service
      render 'index'
    end

    def show
      @service_id = params[:service_id]
      @api_json_endpoint_url = 'saved value 1'
      @api_json_endpoint_key = 'saved value 2'
      # @api_json_endpoint_url = api_json_endpoint_url
      # @api_json_endpoint_key = api_json_endpoint_key
    end

    def update
      @api_json_endpoint_url = params[:api_json_endpoint_url]
      @api_json_endpoint_key = params[:api_json_endpoint_key]
      # render 'admin/services/show', id: params[:service_id]
      render 'admin/services/show'
    end
  end
end
