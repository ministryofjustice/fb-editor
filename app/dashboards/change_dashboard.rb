require 'administrate/custom_dashboard'

# `Change` is not an ActiveRecord model; this dashboard exists only so
# Administrate's navigation (which auto-discovers a dashboard per admin
# resource) can render the "Changes" link without raising. The page itself
# lists AdminEvent records via Admin::ChangesController.
class ChangeDashboard < Administrate::CustomDashboard
  resource 'Change' # used by administrate in the views
end
