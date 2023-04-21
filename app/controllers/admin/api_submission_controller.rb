module Admin
  class ApiSubmissionController < Admin::ApplicationController
    # :instance_accessor
    # cattr_accessor :api_json_endpoint_url
    # attr_accessor :api_json_endpoint_url, :api_json_endpoint_key

    def show
      @api_json_endpoint_url = 'saved value 1'
      @api_json_endpoint_key = 'saved value 2'
      # @api_json_endpoint_url = api_json_endpoint_url
      # @api_json_endpoint_key = api_json_endpoint_key
    end

    def api_json_endpoint_url
      # @api_json_endpoint_url ||= service_config.decrypt_value if service_config.present?
      'default value'
    end

    def api_json_endpoint_key
      # @api_json_endpoint_key ||= service_config.decrypt_value if service_config.present?
      'default value 2'
    end

    def update
      @api_json_endpoint_url = params[:api_json_endpoint_url]
      @api_json_endpoint_key = params[:api_json_endpoint_key]
      # render 'admin/services/show', id: params[:service_id]
      render 'admin/services/show'
    end

    private

    def service_config
      @service_config ||= ServiceConfiguration.find_by(
        service_id: params[:service_id],
        name: 'SERVICE_OUTPUT_JSON_ENDPOINT'
      )
    end
  end
end
