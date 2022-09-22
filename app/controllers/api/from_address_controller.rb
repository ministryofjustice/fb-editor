module Api
  class FromAddressController < ApiController
    include FromAddressObjects

    before_action :assign_from_address

    def resend_validation
      if from_address_creation.resend_validation
        head :ok
      else
        head :bad_request
      end
    end

    def from_address_params
      {}
    end
  end
end
