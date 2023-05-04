module Admin
  class ApiSubmissionController < FormController
    before_action :assign_form_objects

    SERVICE_OUTPUT_JSON_ENDPOINT = 'SERVICE_OUTPUT_JSON_ENDPOINT'.freeze
    SERVICE_OUTPUT_JSON_KEY = 'SERVICE_OUTPUT_JSON_KEY'.freeze

    def assign_form_objects
      @api_submission_settings_dev = ApiSubmissionSettings.new(
        service:,
        deployment_environment: 'dev'
      )
      @api_submission_settings_production = ApiSubmissionSettings.new(
        service:,
        deployment_environment: 'production'
      )
    end

    def index; end

    def create
      @api_submission = ApiSubmissionSettings.new(
        api_submission_settings_params.merge(service:)
      )
      if @api_submission.valid?
        Admin::ApiSubmissionSettingsUpdater.new(
          api_submission_settings: @api_submission,
          service:
        ).create_or_update!

        redirect_to admin_service_api_submission_index_path(service_id: service.service_id)
      else
        flash[:error] = 'api submission is not valid'
        render :index, status: :unprocessable_entity
      end
    end

    private

    def api_submission_settings_params
      params[:admin_api_submission_settings].permit(
        :deployment_environment,
        :service,
        :service_output_json_endpoint,
        :service_output_json_key
      )
    end
  end
end
