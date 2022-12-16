class ApplicationController < ActionController::Base
  include Auth0Helper

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
    payment_link_config.decrypt_value
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
    payment_link_config.present?
  end
  helper_method :payment_link_enabled?

  def payment_link_config
    @payment_link_config ||= ServiceConfiguration.find_by(service_id: service.service_id, name: 'PAYMENT_LINK')
  end
end
