class Settings::ReferenceNumberController < FormController
  before_action :assign_form_objects

  def index
    @reference_number = ReferenceNumberSettings.new(service_id: service.service_id)
  end

  def create
    @reference_number = ReferenceNumberSettings.new(
      reference_number_param.merge(service_id: service.service_id)
    )

    if @reference_number.valid?
      ReferenceNumberUpdater.new(
        reference_number_settings: @reference_number,
        service_id: service.service_id
      ).create_or_update!

      redirect_to settings_reference_number_index_path(service_id: service.service_id)
    else
      render :index, status: :unprocessable_entity
    end
  end

  private

  def assign_form_objects
    @reference_number = ReferenceNumberSettings.new(service_id: service.service_id)
  end

  def reference_number_param
    params.require(:reference_number_settings).permit(:reference_number)
  end
end
