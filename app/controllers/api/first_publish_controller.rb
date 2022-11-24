module Api
  class FirstPublishController < ApiController
    def show
      environment = params[:environment]
      latest_publish = PublishService.where(
        service_id: service.service_id,
        deployment_environment: environment
      )&.last

      url = PublishServicePresenter.new(latest_publish, service).url
      if url
        uri = URI(url)
        Net::HTTP.get(uri)
        head :ok
      end
    rescue SocketError
      head :not_found
    end
  end
end
