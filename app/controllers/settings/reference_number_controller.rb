class Settings::ReferenceNumberController < FormController
  before_action :assign_form_object, only: :index

  def index; end

  def create
    @reference_number = ReferenceNumberSettings.new(
      reference_number_param.merge(service_id: service.service_id)
    )

    redirect_to settings_reference_number_index_path(service_id: service.service_id)
  end

  private

  def assign_form_object
    @reference_number = ReferenceNumberSettings.new(service_id: service.service_id)
  end

  def reference_number_param
    params.require(:reference_number_settings)
  end
end
