module Api
  class ExternalStartPageController < ApiController
    before_action :assign_url

    def new
      render @external_url, layout: false
    end

    def create
      external_url.url = external_url_params['external_start_page_url']['url']
      if external_url.valid?
        external_url_config.value = @external_url.url
        if external_url_config.save!
          # also create a dev env setting
          dev_external_url_config.value = external_url_params['external_start_page_url']['url']
          dev_external_url_config.save!

          redirect_to edit_service_path(service.service_id)
        else
          render external_url, layout: false, status: :unprocessable_entity
        end
      else
        render external_url, layout: false, status: :unprocessable_entity
      end
    end

    def destroy
      external_url_config = ServiceConfiguration.find_by(
        service_id: params['service_id'],
        deployment_environment: 'production',
        name: 'EXTERNAL_START_PAGE_URL'
      )

      if external_url_config.present?
        external_url_config.delete

        # also clean up dev env config
        dev_external_url_config.delete
      end
      redirect_to edit_service_path(external_url_params['service_id'])
    end

    def preview
      external_url_config

      render 'api/external_start_page_urls/preview', layout: false
    end

    def external_start_page_url
      value = external_url_config.decrypt_value
      # ensure url is absolute - we limit to only gov.uk urls which will be https
      unless value[/\Ahttps:\/\//]
        return "https://#{value}"
      end

      value
    end
    helper_method :external_start_page_url

    def first_page_url
      File.join(preview_service_path(service.service_id), service.pages[1].url)
    end
    helper_method :first_page_url

    def editing?
      external_url_config.value.presence
    end
    helper_method :editing?

    private

    def assign_url
      if external_url_config.present?
        external_url.url = external_url_config.decrypt_value
      end
    end

    def external_url
      @external_url ||= ExternalStartPageUrl.new
    end

    def external_url_config
      @external_url_config ||= ServiceConfiguration.find_or_initialize_by(
        service_id: external_url_params['service_id'],
        deployment_environment: 'production',
        name: 'EXTERNAL_START_PAGE_URL'
      )
    end

    def dev_external_url_config
      @dev_external_url_config ||= ServiceConfiguration.find_or_initialize_by(
        service_id: external_url_params['service_id'],
        deployment_environment: 'dev',
        name: 'EXTERNAL_START_PAGE_URL'
      )
    end

    def external_url_params
      params.permit(
        :authenticity_token,
        { external_start_page_url: %i[url] },
        :service_id
      )
    end
  end
end
