module Admin
  class ApiSubmissionController < Admin::ApplicationController
    def show
      @api_json_endpoint_url = 'saved value 1'
      @api_json_endpoint_key = 'saved value 2'
    end

    def api_json_endpoint_url
      'default value'
    end

    def api_json_endpoint_key
      'default value'
    end

    def update
      @api_json_endpoint_url = params[:api_json_endpoint_url]
      @api_json_endpoint_key = params[:api_json_endpoint_key]
      render 'admin/services/show', service[:service_id]
    end
  end
end
