module Api
  class FromAddressController < ApiController
    before_action :assign_from_address

    def resend_validation
      from_address_creation = FromAddressCreation.new(
        from_address: @from_address,
        from_address_params: {},
        email_service: email_service
      )

      if from_address_creation.resend_validation
        head :ok
      else
        head :bad_request
      end
    end

    private

    def assign_from_address
      @from_address = FromAddress.find_or_initialize_by(service_id: service.service_id)
    end

    def email_service
      @email_service ||= if Rails.env.production?
                           EmailService::Adapters::AwsSesClient.new
                         else
                           EmailService::Adapters::Local.new
                         end
    end
  end
end
