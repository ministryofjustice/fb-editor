# app/dashboards/stat_dashboard.rb
require 'administrate/custom_dashboard'

class ApiSubmissionDashboard < Administrate::CustomDashboard
  resource 'api_submission' # used by administrate in the views
end
