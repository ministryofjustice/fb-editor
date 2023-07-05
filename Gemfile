source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.3'

gem 'activerecord-session_store'
gem 'administrate'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'daemons'
gem 'delayed_job_active_record'

# Metadata presenter - if you need to be on development you can uncomment
# one of these lines:
# gem 'metadata_presenter',
#     github: 'ministryofjustice/fb-metadata-presenter',
#     branch: 'standalone-pages-notification-banners'
# gem 'metadata_presenter', path: '../fb-metadata-presenter'
gem 'metadata_presenter', '3.0.11'

gem 'aws-sdk-s3'
gem 'aws-sdk-sesv2'
gem 'faraday'
gem 'faraday_middleware'
gem 'fb-jwt-auth', '0.10.0'
gem 'govuk-components'
gem 'govuk_design_system_formbuilder'
gem 'hashie'
gem 'omniauth-auth0', '~> 3.1.0'
gem 'omniauth-rails_csrf_protection', '~> 1.0.1'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 6.3'
gem 'rails', '~> 7.0'
gem 'sass-rails', '>= 6'
gem 'sentry-delayed_job', '~> 5.8.0'
gem 'sentry-rails', '~> 5.8.0'
gem 'sentry-ruby', '~> 5.8.0'
gem 'tzinfo-data'
gem 'webpacker', '~> 5.4'

gem 'govspeak', '~> 7.1'

group :development, :test do
  gem 'brakeman'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'capybara'
  gem 'dotenv-rails', groups: %i[development test]
  gem 'factory_bot_rails'
  gem 'rspec_junit_formatter'
  gem 'rspec-rails'
  gem 'selenium-webdriver', '4.8.0'
  gem 'shoulda-matchers'
  gem 'site_prism'
  gem 'webmock'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'listen', '~> 3.8'
  gem 'rubocop', '~> 1.44.1'
  gem 'rubocop-govuk'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.1.0'
  gem 'web-console', '>= 3.3.0'
end
