module Api
  class FirstPublishController < ApiController

    def show
      uri = URI('https://testing-initial-publish-response.test.form.service.justice.gov.uk')
      Net::HTTP.get(uri)
      head 200
    rescue SocketError
      head 404
    end
  end
end
