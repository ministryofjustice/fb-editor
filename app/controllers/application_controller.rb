class ApplicationController < ActionController::Base
  include Auth0Helper

  def service
    @service ||= MetadataPresenter::Service.new(service_metadata, editor: editable?)
  end
  helper_method :service

  def editable?
    !request.script_name.include?('preview')
  end
  helper_method :editable?

  def back_link; end
  helper_method :back_link

  def save_user_data
    return {} if params[:answers].blank? || params[:id].blank?

    service_id = params[:id]
    session[service_id] ||= {}
    session[service_id]['user_data'] ||= {}

    params[:answers].each do |field, answer|
      session[service_id]['user_data'][field] = if answer.respond_to?(:original_filename)
                                                  {
                                                    'original_filename' => answer.original_filename
                                                  }
                                                else
                                                  answer
                                                end
    end
  end

  def load_user_data
    user_data = session[params[:id]] || {}

    user_data['user_data'] || {}
  end

  def remove_user_data(component_id)
    user_data = session[params[:id]] || {}
    user_data['user_data'].delete(component_id)
    user_data['user_data']
  end

  def upload_file
    user_data = load_user_data
    @page_answers.page.upload_components.each do |component|
      answer = user_data[component.id]

      if answer.present?
        @page_answers.answers[component.id] = answer
      end

      file = OpenStruct.new(
        file: @page_answers.send(component.id),
        component: component
      )
      @page_answers.uploaded_files.push(file)
    end
  end

  def service_metadata
    @service_metadata ||= MetadataApiClient::Service.latest_version(params[:id])
  end

  def user_name
    if current_user
      current_user.name.split(' ').tap do |full_name|
        return "#{full_name.first[0]}. #{full_name.last}"
      end
    end
  end
  helper_method :user_name
end
