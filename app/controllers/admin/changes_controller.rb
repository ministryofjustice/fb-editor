module Admin
  class ChangesController < Admin::ApplicationController
    def index
      @admin_events = AdminEvent.recent.includes(:user).limit(50)
    end
  end
end
