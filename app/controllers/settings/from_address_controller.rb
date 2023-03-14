class Settings::FromAddressController < FormController
  def index; end

  def from_address_params
    params.require(:from_address).permit(:email)
  end
end
