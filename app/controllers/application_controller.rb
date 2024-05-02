class ApplicationController < ActionController::Base
  include SetCurrentRequestDetails
  include Auth0Helper
  helper_method :current_user

  def service
    @service ||= MetadataPresenter::Service.new(service_metadata, editor: editable?)
  end
  helper_method :service

  def grid
    @grid ||= MetadataPresenter::Grid.new(service)
  end
  helper_method :grid

  def editable?
    !request.script_name.include?('preview')
  end
  helper_method :editable?

  def back_link; end
  helper_method :back_link

  def show_form_navigation?
    %w[home user_sessions].exclude?(controller_name) &&
      !(controller_name == 'services' && action_name == 'index')
  end
  helper_method :show_form_navigation?

  def save_user_data
    return {} if params[:id].blank?

    Preview::SessionDataAdapter.new(session, params[:id]).save(answer_params)
  end

  def load_user_data
    Preview::SessionDataAdapter.new(session, params[:id]).load_data
  end

  def remove_user_data(component_id)
    Preview::SessionDataAdapter.new(session, params[:id]).delete(component_id)
  end

  def remove_file_from_data(component_id, file_id)
    Preview::SessionDataAdapter.new(session, params[:id]).delete_file(component_id, file_id)
  end

  def answer_params
    Preview::AnswerParams.new(@page_answers).answers
  end

  def upload_adapter
    MetadataPresenter::OfflineUploadAdapter
  end

  def service_metadata
    @service_metadata ||= MetadataApiClient::Service.latest_version(service_id_param)
  end

  def user_name
    if current_user
      current_user.name.split(' ').tap do |full_name|
        return "#{full_name.first[0]}. #{full_name.last}"
      end
    end
  end
  helper_method :user_name

  def service_id_param
    params[:service_id] || params[:id]
  end

  def autocomplete_items(components)
    components.each_with_object({}) do |component, hash|
      next unless component.type == 'autocomplete'

      response = MetadataApiClient::Items.find(service_id: service.service_id, component_id: component.uuid)

      if response.errors?
        Rails.logger.info(response.errors)
      else
        hash[component.uuid] = response.metadata['items'][component.uuid]
      end
    end
  end

  def show_reference_number
    I18n.t('default_values.reference_number')
  end
  helper_method :show_reference_number

  def payment_link_url
    '#' # We don't have a real reference number so we can't link anywhere.
  end
  helper_method :payment_link_url

  def reference_number_enabled?
    reference_number_config.present?
  end
  helper_method :reference_number_enabled?

  def reference_number_config
    @reference_number_config ||= ServiceConfiguration.find_by(service_id: service.service_id, name: 'REFERENCE_NUMBER')
  end

  def payment_link_enabled?
    SubmissionSetting.find_by(
      service_id: service.service_id,
      deployment_environment: 'dev'
    ).try(:payment_link?)
  end
  helper_method :payment_link_enabled?

  def payment_link_config
    @payment_link_config ||= ServiceConfiguration.find_by(service_id: service.service_id, name: 'PAYMENT_LINK')
  end

  def allowed_page?
    true
  end
  helper_method :allowed_page?

  def session_expiry_time
    session[:expires_at]
  end
  helper_method :session_expiry_time

  def save_and_return_enabled?
    save_and_return_config.present?
  end
  helper_method :save_and_return_enabled?

  def using_external_start_page?
    external_start_page_config.present?
  end
  helper_method :using_external_start_page?

  def external_url
    return '' unless using_external_start_page?

    external_start_page_config.decrypt_value
  end
  helper_method :external_url

  def connection_activator_text(item, condition_title = '')
    title = using_external_start_page? ? I18n.t('external_start_page_url.link') : item[:title]
    (item[:type] == 'flow.branch' ? "#{title}, #{condition_title}" : title)
  end
  helper_method :connection_activator_text

  def show_save_and_return
    @page.upload_components.none?
  end
  helper_method :show_save_and_return

  def save_and_return_config
    @save_and_return_config ||= ServiceConfiguration.find_by(service_id: service.service_id, name: 'SAVE_AND_RETURN')
  end

  def external_start_page_config
    @external_start_page_config ||= ServiceConfiguration.find_by(service_id: service.service_id, name: 'EXTERNAL_START_PAGE_URL', deployment_environment: 'production')
  end

  def editor_preview?
    request.script_name.include?('preview')
  end
  helper_method :editor_preview?

  def single_page_preview?
    return true if request.referer.blank?

    !URI(request.referer).path.split('/').include?('preview')
  end
  helper_method :single_page_preview?

  def service_slug
    return service_slug_config if service_slug_config.present?

    service.service_slug
  end

  def service_slug_config
    ServiceConfiguration.find_by(
      service_id: service.service_id,
      name: 'SERVICE_SLUG',
      deployment_environment: 'dev'
    )&.decrypt_value
  end

  def confirmation_email_enabled?
    confirmation_email_config.present?
  end
  helper_method :confirmation_email_enabled?

  def confirmation_email_config
    @confirmation_email_config ||= ServiceConfiguration.find_by(service_id: service.service_id, name: 'CONFIRMATION_EMAIL_COMPONENT_ID')
  end

  def confirmation_email
    confirmation_email_component_id = ServiceConfiguration.find_by(service_id: service.service_id, name: 'CONFIRMATION_EMAIL_COMPONENT_ID')&.decrypt_value
    user_data = Preview::SessionDataAdapter.new(session, service.service_id).load_data
    @confirmation_email ||= user_data[confirmation_email_component_id] if confirmation_email_enabled?
  end
  helper_method :confirmation_email

  def is_confirmation_email_question?(component_id)
    confirmation_email_config&.decrypt_value == component_id
  end
  helper_method :is_confirmation_email_question?

  def in_runner?; end
  helper_method :in_runner?

  def first_page?
    @page.url == service.pages[1].url
  end
  helper_method :first_page?

  def use_external_start_page?
    external_start_page_config.present?
  end
  helper_method :use_external_start_page?

  def external_start_page_url
    if external_start_page_config.present?
      value = external_start_page_config.decrypt_value
      unless value[/\Ahttps:\/\//]
        return "https://#{value}"
      end

      value
    else
      ''
    end
  end
  helper_method :external_start_page_url

  def start_page_url
    external_start_page_url.empty? ? root_path : external_start_page_url
  end
  helper_method :start_page_url

  def page_title
    'MoJ Forms'
  end
  helper_method :page_title
end
