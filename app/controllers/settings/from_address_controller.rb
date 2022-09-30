class Settings::FromAddressController < FormController
  include FromAddressObjects

  before_action :assign_from_address, :assign_from_address_presenter

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

  private

  def assign_from_address_presenter
    @presenter = FromAddressPresenter.new(
      from_address: @from_address,
      messages: I18n.t('warnings.from_address.settings'),
      service_id: service.service_id
    )
  end
end
