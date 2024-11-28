class HomeController < ApplicationController
  def show
    redirect_to services_path if user_signed_in?

    @sign_in_url = if Rails.env.development?
                     '/auth/developer'
                   else
                     '/auth/cognito-idp'
                   end
  end

  def page_title
    I18n.t('home.show.title')
  end
  helper_method :page_title
end
