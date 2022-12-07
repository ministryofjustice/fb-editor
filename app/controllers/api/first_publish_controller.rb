module Api
  class FirstPublishController < ApiController
    def show
      environment = params[:environment]
      publishes = PublishService.where(
        service_id: service.service_id,
        deployment_environment: environment
      ).published

      url = PublishServicePresenter.new(publishes, service).url
      if url
        dns = ::Resolv::DNS.new(nameserver: '1.1.1.1')
        dns.getaddress(url)
        head :ok
      end
    rescue ::Resolv::ResolvError
      head :not_found
    end
  end
end
