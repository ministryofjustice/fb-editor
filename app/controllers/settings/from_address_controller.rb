class Settings::FromAddressController < FormController
  include FromAddressObjects

  before_action :assign_from_address

  def index; end

  def create
    if from_address_creation.save
      redirect_to settings_from_address_index_path(service.service_id)
    else
      render :index
    end
  end

  def from_address_params
    params.require(:from_address).permit(:email)
  end
end
