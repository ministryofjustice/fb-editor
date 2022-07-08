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

  def items_present?(component_id)
    return if @service_items.blank?

    @service_items.key?(component_id)
  end
  helper_method :items_present?
end
