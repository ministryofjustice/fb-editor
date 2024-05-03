class Settings::EmailController < FormController
  before_action :assign_form_objects

  def create
    @email_settings = EmailSettings.new(
      email_settings_params.merge(service:)
    )

    if @email_settings.valid?
      EmailSettingsUpdater.new(
        email_settings: @email_settings,
        service:
      ).create_or_update!

      redirect_to settings_email_index_path(service_id: service.service_id)
    else
      if email_settings_params[:deployment_environment] == 'dev'
        @email_settings_dev = @email_settings
      else
        @email_settings_production = @email_settings
      end
      render :index, status: :unprocessable_entity
    end
  end

  def email_settings_params
    email_params.permit(
      :deployment_environment,
      :send_by_email,
      :service_email_output,
      :service_email_subject,
      :service_email_body,
      :service_email_pdf_heading,
      :service_email_pdf_subheading,
      :service_csv_output
    )
  end

  def page_title
    I18n.t('settings.collection_email.heading')
  end
  helper_method :page_title

  private

  def email_params
    params.require(:email_settings).tap do |settings|
      settings[:send_by_email] = settings[send_by_email(settings)]
    end
  end

  def send_by_email(settings)
    "send_by_email_#{settings[:deployment_environment]}"
  end

  def assign_form_objects
    @email_settings_dev = EmailSettings.new(
      service:,
      deployment_environment: 'dev'
    )
    @email_settings_production = EmailSettings.new(
      service:,
      deployment_environment: 'production'
    )
  end
end
