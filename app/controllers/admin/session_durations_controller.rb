module Admin
  class SessionDurationsController < Admin::ApplicationController
    def show
      @session_duration = session_duration
    end

    def session_duration
      @session_duration ||=
        if service_config.present?
          service_config.decrypt_value
        else
          '30'
        end
    end

    def edit(new_session_duration)
      @session_duration = new_session_duration
    end

    private

    def service_config
      @service_config ||= ServiceConfiguration.find_by(
        service_id: params[:service_id],
        name: 'SESSION_DURATION'
      )
    end
  end
end
