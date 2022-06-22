class PermissionsController < ApplicationController
  include ApplicationHelper
  include AuthorisationHelper

  before_action :require_user!
  before_action :authorised_access
end
