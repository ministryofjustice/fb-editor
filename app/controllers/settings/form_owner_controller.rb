class Settings::FormOwnerController < FormController
  before_action :assign_form_object, only: :index

  def index; end

  def update
    @form_owner = FormOwnerSettings.new(service_id: service.service_id, metadata: service.to_h, form_owner: params[:form_owner_settings][:form_owner])
    if @form_owner.update
      send_confirmation_email
      transfer_params = {
        service: @service.service_name,
        owner: params[:form_owner_settings][:form_owner]
      }
      redirect_to services_path(params: transfer_params)
    else
      render :index
    end
  end

  private

  # We have to initialise the form setting so it does not fail in the view and we can show the error
  def assign_form_object
    @form_owner = FormOwnerSettings.new
  end

  def send_confirmation_email
    EmailService::Emailer.send_mail(
      to: @form_owner,
      subject: 'Transfer of Ownership',
      raw_message: '<h1>Sample Email</h1>'
    )
  end
end
