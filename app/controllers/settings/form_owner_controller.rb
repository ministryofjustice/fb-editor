class Settings::FormOwnerController < FormController
  before_action :assign_form_object, only: :index

  def index; end

  def update
    previous_owner_email = User.find(service.created_by).email
    new_owner_email = form_owner_params[:form_owner]
    @form_owner_settings = FormOwnerSettings.new(service_id: service.service_id, metadata: service.to_h, form_owner: new_owner_email)

    if @form_owner_settings.update
      send_ownership_transfer_emails(previous_owner_email:, new_owner_email:)
      record_ownership_transfer_admin_event(previous_owner_email:, new_owner_email:)
      redirect_to services_path(params: { service: service.service_name, owner: new_owner_email })
    else
      render :index
    end
  end

  def page_title
    "#{I18n.t('settings.transfer_ownership.heading')} - Settings - MoJ Forms"
  end
  helper_method :page_title

  private

  # We have to initialise the form setting so it does not fail in the view and we can show the error
  def assign_form_object
    @form_owner_settings = FormOwnerSettings.new
  end

  def form_owner_params
    params.require(:form_owner_settings).permit(:form_owner)
  end

  def send_ownership_transfer_emails(previous_owner_email:, new_owner_email:)
    ownership_transfer_email_args = {
      service_name: service.service_name,
      previous_owner: previous_owner_email,
      new_owner: new_owner_email
    }
    TransferOwnershipMailer.transfer_ownership(**ownership_transfer_email_args).deliver_later
    TransferOwnershipMailer.transfer_ownership_confirmation(**ownership_transfer_email_args).deliver_later
  end

  def record_ownership_transfer_admin_event(previous_owner_email:, new_owner_email:)
    AdminEvent.create!(
      user_id: current_user.id,
      service_id: service.service_id,
      action: I18n.t(
        'settings.transfer_ownership.admin_event',
        previous_owner_email:, new_owner_email:, locale: :en
      )
    )
  end
end
