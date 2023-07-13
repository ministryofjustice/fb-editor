module Preview
  class SessionDataAdapter
    attr_reader :session, :service_id

    def initialize(session, service_id)
      @session = session
      @service_id = service_id
    end

    def save(answers)
      return {} if answers.blank?

      session[service_id] ||= {}
      session[service_id]['user_data'] ||= {}

      answers.each do |field, answer|
        session[service_id]['user_data'][field] = answer
      end
    end

    def load_data
      user_data = session[service_id] || {}
      user_data['user_data'] || {}
    end

    def delete(component_id)
      user_data = session[service_id] || {}
      user_data['user_data'].delete(component_id)
      user_data['user_data']
    end

    def delete_file(component_id, file_id)
      user_data = session[service_id] || {}
      user_data['user_data'][component_id] = user_data['user_data'][component_id].reject { |f| f['uuid'] == file_id }
    end
  end
end
