class HomeController < ApplicationController
  def show
    redirect_to services_path if user_signed_in?

    @sign_in_url = if Rails.env.development?
                     '/auth/developer'
                   else
                     '/auth/auth0'
                   end
  end

  def page_title
    "Sign in - MoJ Forms"
  end
  helper_method :page_title
end
