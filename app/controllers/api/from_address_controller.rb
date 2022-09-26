module Api
  class FromAddressController < ApiController
    include FromAddressObjects

    before_action :assign_from_address

    def resend_validation
      from_address_creation.resend_validation

      head :ok
    end

    def from_address_params
      {}
    end
  end
end
