# All Administrate controllers inherit from this
# `Administrate::ApplicationController`, making it the ideal place to put
# authentication logic or other before_actions.
#
# If you want to add pagination or other controller-level concerns,
# you're free to overwrite the RESTful controller actions.
module Admin
  class ApplicationController < Administrate::ApplicationController
    include ApplicationHelper
    include Auth0Helper
    before_action :require_user!
    before_action :authenticate_admin

    def authenticate_admin
      redirect_to login_path unless moj_forms_team_member?
    end

    def moj_forms_dev?
      Rails.application.config.moj_forms_devs.include?(current_user.email)
    end

    # Override this value to specify the number of elements to display at a time
    # on index pages. Defaults to 20.
    # def records_per_page
    #   params[:per_page] || 20
    # end
  end
end
