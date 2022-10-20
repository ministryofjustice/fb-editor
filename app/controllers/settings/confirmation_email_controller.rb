class Settings::ConfirmationEmailController < FormController
  before_action :assign_form_objects, :assign_from_address_presenter

  def index; end

  def create
    @confirmation_email = ConfirmationEmailSettings.new(
      confirmation_email_settings_params.merge(service: service, from_address: from_address)
    )

    if @confirmation_email.valid?
      ConfirmationEmailSettingsUpdater.new(
        confirmation_email_settings: @confirmation_email,
        service: service
      ).create_or_update!

      redirect_to settings_confirmation_email_index_path(service_id: service.service_id)
    else
      if confirmation_email_settings_params[:deployment_environment] == 'dev'
        @confirmation_email_settings_dev = @confirmation_email
      else
        @confirmation_email_settings_production = @confirmation_email
      end
      render :index, status: :unprocessable_entity
    end
  end

  def confirmation_email_settings_params
    confirmation_email_params.permit(
      :deployment_environment,
      :send_by_confirmation_email,
      :confirmation_email_component_id,
      :confirmation_email_subject,
      :confirmation_email_body
    )
  end

  private

  def assign_form_objects
    @confirmation_email_settings_dev = ConfirmationEmailSettings.new(
      service: service,
      deployment_environment: 'dev',
      from_address: from_address
    )
    @confirmation_email_settings_production = ConfirmationEmailSettings.new(
      service: service,
      deployment_environment: 'production',
      from_address: from_address
    )
    @email_components = email_components
  end

  def confirmation_email_params
    params.require(:confirmation_email_settings).tap do |settings|
      settings[:send_by_confirmation_email] = settings[send_by_confirmation_email(settings)]
    end
  end

  def send_by_confirmation_email(settings)
    "send_by_confirmation_email_#{settings[:deployment_environment]}"
  end

  def assign_from_address_presenter
    @from_address_presenter = FromAddressPresenter.new(
      from_address: from_address,
      messages: I18n.t('warnings.email_settings'),
      service_id: service.service_id
    )
  end

  def from_address
    @from_address ||= FromAddress.find_or_initialize_by(service_id: service.service_id)
  end

  def email_components
    @email_components ||= begin
      components = service.pages.map(&:components).flatten
      components.select { |component| component.type == 'email' }
    end
  end
end
