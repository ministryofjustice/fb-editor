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
    emailer = EmailService::Emailer.new

    body = I18n.t('activemodel.errors.models.transfer_ownership.confirmation_email.subject',
                  service_name:,
                  previous_owner:,
                  href: I18n.t('activemodel.errors.models.transfer_ownership.href'))

    emailer.send_mail(
      to: new_owner,
      subject: I18n.t('activemodel.errors.models.transfer_ownership.confirmation_email.body'),
      body:,
      html: body
    )
  end
end
