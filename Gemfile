source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.5'

gem 'activerecord-session_store'
gem 'administrate'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'daemons'
gem 'delayed_job_active_record'

# Metadata presenter - if you need to be on development you can uncomment
# one of these lines:
# gem 'metadata_presenter',
#    github: 'ministryofjustice/fb-metadata-presenter',
#    branch: 'add-branching-title'
# gem 'metadata_presenter', path: '../fb-metadata-presenter'
gem 'metadata_presenter', '2.17.4'

gem 'faraday'
gem 'faraday_middleware'
gem 'fb-jwt-auth', '0.8.0'
gem 'hashie'
gem 'omniauth-auth0', '~> 3.0.0'
gem 'omniauth-rails_csrf_protection', '~> 1.0.1'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 5.6'
gem 'rails', '~> 6.1.6'
gem 'sass-rails', '>= 6'
gem 'sentry-delayed_job', '~> 5.3.1'
gem 'sentry-rails', '~> 5.3.1'
gem 'sentry-ruby', '~> 5.3.1'
gem 'tzinfo-data'
gem 'webpacker', '~> 5.4'

group :development, :test do
  gem 'brakeman'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'capybara'
  gem 'dotenv-rails', groups: %i[development test]
  gem 'factory_bot_rails'
  gem 'rspec_junit_formatter'
  gem 'rspec-rails'
  gem 'selenium-webdriver', '4.3.0'
  gem 'shoulda-matchers'
  gem 'site_prism'
  gem 'webmock'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'listen', '~> 3.7'
  gem 'rubocop', '~> 1.30.1'
  gem 'rubocop-govuk'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end
