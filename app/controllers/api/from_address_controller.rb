module Api
  class FromAddressController < ApiController
    def index
      from_address = FromAddress.find(service_id: params[:id])
      if from_address.verified
        # render 200 with message
      elsif from_address.pending
        # render 200 with message
      else
        # unverified
      end
    end
  end
end
