class Settings::FormNameUrlController < FormController
  before_action :assign_form_object, only: :index
  before_action :create_service_slug_config, only: :index

  def index; end

  def create
    @form_name_url_settings = FormNameUrlSettings.new(service_params)

    if @form_name_url_settings.create
      FormUrlUpdater.new(
        service_id: service.service_id,
        service_slug: params[:service][:service_slug]
      ).create_or_update!

      redirect_to settings_form_name_url_index_path(service.service_id)
    else
      render :index
    end
  end

  def page_title
    "#{I18n.t('settings.form_name.heading')} - Settings - MoJ Forms"
  end
  helper_method :page_title

  private

  def service_params
    params.require(:service).permit(:service_name, :service_slug).merge(
      service_id: service.service_id,
      latest_metadata: service.to_h
    )
  end

  def assign_form_object
    @form_name_url_settings = FormNameUrlSettings.new(
      service_id: service.service_id,
      latest_metadata: service.to_h,
      service_name: service.service_name,
      service_slug:
    )
  end

  def service_slug_config
    ServiceConfiguration.find_by(
      service_id: service.service_id,
      name: 'SERVICE_SLUG',
      deployment_environment: 'dev'
    )&.decrypt_value
  end

  def create_service_slug_config
    if service_slug_config.blank?
      FormUrlUpdater.new(
        service_id: service.service_id,
        service_slug:
      ).create_or_update!
    end
  end
end
