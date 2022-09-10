class Settings::FromAddressController < FormController
  before_action :assign_from_address

  def index; end

  def create
    @from_address.update!(from_address_params)

    redirect_to settings_from_address_index_path(params[:id])
  rescue ActiveRecord::RecordInvalid
    render :index
  end

  def from_address_params
    params.require(:from_address).permit(:email)
  end

  private

  def assign_from_address
    # initialize for those forms that were created before FromAddress records existed
    @from_address = FromAddress.find_or_initialize_by(service_id: params[:id])
  end
end
