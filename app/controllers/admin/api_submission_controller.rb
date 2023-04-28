module Admin
  class ApiSubmissionController < Admin::ApplicationController
    attr_reader :service_id

    # def initialize
    #   Rails.logger.debug 'It is a new controller'
    #   @api_submission = Admin::ApiSubmission.new
    #   super
    # end

    # def index
    #   # we save the service field to be send as hidden field
    #   @service_id = params[:service_id]
    #   @api_submission.service_id(params[:service_id])
    #   show
    #   render 'index'
    # end

    # def create
    #   url = params[:admin_api_submission][:endpoint_url]
    #   key = params[:admin_api_submission][:endpoint_key]
    #   @api_submission.service_id(params[:service_id])
    #   @api_submission.deployment_environment(params[:admin_api_submission][:deployment_environment])
    #   if url.blank? || key.blank?
    #     flash[:error] = 'Please use the delete button to delete API settings'
    #   else
    #     @api_submission.create_service_configurations(url, key)
    #     flash[:success] = 'API submission settings successfully updated'
    #   end
    #   # render 'admin/services/show', object: @service
    #   render 'index'
    # end

    # def delete
    #   Rails.logger.debug 'We have to delete'
    #   @api_submission.delete_service_configurations
    #   render 'index'
    # end

    SERVICE_OUTPUT_JSON_ENDPOINT = 'SERVICE_OUTPUT_JSON_ENDPOINT'.freeze
    SERVICE_OUTPUT_JSON_KEY = 'SERVICE_OUTPUT_JSON_KEY'.freeze

    # def show
    #   Rails.logger.debug 'We show'
    #   @url_dev = url_dev
    #   @url_prod = url_prod
    #   @key_dev = key_dev
    #   @key_prod = key_prod
    # end

    def url_dev
      @service_id = params[:service_id]
      config = service_config(service_id: @service_id, deployment_environment: 'dev', name: SERVICE_OUTPUT_JSON_ENDPOINT)
      @url_dev ||=
        begin
          return config.decrypt_value if config.present?

          'default1'
        end
    end

    def key_dev
      @service_id = params[:service_id]
      config = service_config(service_id: @service_id, deployment_environment: 'dev', name: SERVICE_OUTPUT_JSON_KEY)
      @key_dev ||=
        begin
          return config.decrypt_value if config.present?

          'default2'
        end
    end

    def url_prod
      @service_id = params[:service_id]
      config = service_config(service_id: @service_id, deployment_environment: 'production', name: SERVICE_OUTPUT_JSON_ENDPOINT)
      @url_prod ||=
        begin
          return config.decrypt_value if config.present?

          'default3'
        end
    end

    def key_prod
      @service_id = params[:service_id]
      config = service_config(service_id: @service_id, deployment_environment: 'production', name: SERVICE_OUTPUT_JSON_KEY)
      @key_prod ||=
        begin
          return config.decrypt_value if config.present?

          'default4'
        end
    end

    def service_config(service_id:, name:, deployment_environment:)
      @service_config ||= ServiceConfiguration.find_by(service_id:, deployment_environment:, name:)
    end

    # def create
    #   @api_submission.service_id(params[:service_id])
    #   @api_submission.deployment_environment(params[:admin_api_submission][:deployment_environment])

    #   case params[:admin_api_submission][:url_or_key]
    #   when 'url'
    #     Rails.logger.debug 'we will create url config'
    #     url = params[:admin_api_submission][:endpoint_url]
    #     Rails.logger.debug url
    #     @api_submission.create_or_update_configuration(name: SERVICE_OUTPUT_JSON_ENDPOINT, value: url)
    #   when 'key'
    #     Rails.logger.debug 'we will create key config'
    #     key = params[:admin_api_submission][:endpoint_key]
    #     Rails.logger.debug key
    #     @api_submission.create_or_update_configuration(name: SERVICE_OUTPUT_JSON_KEY, value: key)
    #   end
    #   # TODO: we may want to change this to show?
    #   render 'show'
    # end

    # need to test udpate as well, maybe create just overrid everything

    # Implementation like version
    # def show; end

    # def edit
    #   flash[:success] = 'We first edit'
    #   @service_id = params[:service_id]
    # end

    # def update
    #   flash[:success] = 'We then update'
    # end

    def list
      @api_submissions = Admin::ApiSubmission.all
    end

    def show
      @api_submission = ApiSubmission.find(params[:api_submission][:id])
    end

    def new
      @api_submission = Admin::ApiSubmission.new
    end

    def create
      @api_submission = ApiSubmission.new(api_settings)
      if @api_submission.save
        flash[:success] = 'API Submission settings saved correctly'
        redirect_to action: 'list'
      else
        flash[:error] = 'API Submission settings did not saved correctly'
        render action: 'new'
      end
    end

    def api_settings
      params.require(:api_submissions).permit(:name, :value, :deployment_environment)
    end

    def update
      @api_submission = ApiSubmission.find(params[:id])

      if @api_submission.update(api_settings)
        flash[:success] = 'API Submission settings saved correctly'
        redirect_to action: 'show', id: @api_submission
      else
        flash[:error] = 'API Submission settings did not saved correctly'
        render action: 'new'
      end
    end

    def delete
      ApiSubmission.find(params[:id]).destroy
      redirect_to action: 'list'
    end
  end
end
