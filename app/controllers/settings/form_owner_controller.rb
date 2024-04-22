class Settings::FormOwnerController < FormController
  before_action :assign_form_object, only: :index

  def index; end

  def update
    previous_owner = User.find(service.created_by).email
    new_owner = params[:form_owner_settings][:form_owner]
    @form_owner = FormOwnerSettings.new(service_id: service.service_id, metadata: service.to_h, form_owner: new_owner)
    if @form_owner.update
      send_confirmation_email(new_owner, @service.service_name, previous_owner)
      transfer_params = {
        service: @service.service_name,
        owner: new_owner
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

  def send_confirmation_email(new_owner, service_name, previous_owner)
    EmailService::Emailer.send_mail(
      to: new_owner,
      subject: 'An MoJ Forms form has been transferred to you',
      body: "#{service_name}\n The following form has been transferred to you: \n#{service_name}\nYou are now able
to access, edit and publish this form. It will be listed on the ‘Your forms’ page when you next sign in to MoJ Forms.\n
Sign in to MoJ Forms\nThis change was requested by #{previous_owner}.\n
If you have any questions, please contact us.",
      html: '<h1>Sample Email</h1>',
      raw: 'It\'s complicated'
    )
  end
end
