class Settings::FormOwnerController < FormController
  def index; end

  def update
    @form_owner = FormOwnerSettings.new(service_id: service.service_id, form_owner: params[:form_owner])
    if @form_owner.update
      redirect_to services_path
    else
      render :index
    end
  end
end
