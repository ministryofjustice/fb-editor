class Settings::ConfirmationEmailController < FormController
  before_action :assign_form_objects

  def index; end

  def create
    @confirmation_email = ConfirmationEmailSettings.new(
      confirmation_email_settings_params.merge(service:)
    )

    if @confirmation_email.valid?
      ConfirmationEmailSettingsUpdater.new(
        confirmation_email_settings: @confirmation_email,
        service:
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
      :confirmation_email_reply_to,
      :deployment_environment,
      :send_by_confirmation_email,
      :confirmation_email_component_id,
      :confirmation_email_subject,
      :confirmation_email_body
    )
  end

  def page_title
    "#{I18n.t('settings.confirmation_email.heading')} - Settings - MoJ Forms"
  end
  helper_method :page_title

  private

  def assign_form_objects
    @confirmation_email_settings_dev = ConfirmationEmailSettings.new(
      service:,
      deployment_environment: 'dev'
    )
    @confirmation_email_settings_production = ConfirmationEmailSettings.new(
      service:,
      deployment_environment: 'production'
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

  def email_components
    @email_components ||= begin
      components = service.pages.map(&:components).flatten
      components.select { |component| component.type == 'email' }
    end
  end
end
