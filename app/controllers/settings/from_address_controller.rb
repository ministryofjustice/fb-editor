class Settings::FromAddressController < FormController
  before_action :assign_from_address

  def index; end

  def create
    from_address_creation = FromAddressCreation.new(
      from_address: @from_address,
      from_address_params: from_address_params,
      email_service: email_service
    )

    if from_address_creation.save
      redirect_to settings_from_address_index_path(service.service_id)
    else
      render :index
    end
  end

  def from_address_params
    params.require(:from_address).permit(:email)
  end

  private

  def assign_from_address
    # initialize for those forms that were created before FromAddress records existed
    @from_address = FromAddress.find_or_initialize_by(service_id: service.service_id)
    @presenter = FromAddressPresenter.new(@from_address)
  end

  def email_service
    @email_service ||= if Rails.env.production?
                         EmailService::Adapters::AwsSesClient.new
                       else
                         EmailService::Adapters::Local.new
                       end
  end
end
