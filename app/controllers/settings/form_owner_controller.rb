class Settings::FormOwnerController < FormController
  before_action :assign_form_object, only: :index

  def index; end

  def update
    # With form_with
    # @form_owner = FormOwnerSettings.new(form_owner: params[:form_owner])
    # With form_for
    @form_owner = FormOwnerSettings.new(service_id: service.service_id, metadata: service.to_h, form_owner: params[:form_owner_settings][:form_owner])
    if @form_owner.update
      # then we want to show the modal
      redirect_to services_path
    else
      render :index
    end
  end

  private

  # We have to initialise the form setting so it does not fail in the view and we can show the error
  def assign_form_object
    @form_owner = FormOwnerSettings.new
  end
end
