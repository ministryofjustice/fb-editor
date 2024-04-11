class Settings::TransferOwnershipController < FormController
  def index
    @form_owner = FormOwnerSettings.new(service_id: service.service_id)
  end
  def update; end
end
