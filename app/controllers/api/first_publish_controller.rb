module Api
  require 'resolv'

  class FirstPublishController < ApiController
    def show
      environment = params[:environment]
      publishes = PublishService.where(
        service_id: service.service_id,
        deployment_environment: environment
      ).published

      hostname = PublishServicePresenter.new(publishes, service).hostname
      if hostname
        dns = Resolv::DNS.new(nameserver: ['8.8.8.8', '8.8.4.4'])
        dns.getaddress(hostname)
        head :ok
      end
    rescue Resolv::ResolvError
      head :not_found
    end
  end
end
