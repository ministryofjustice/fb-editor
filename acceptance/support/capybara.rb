Capybara.register_driver :selenium do |app|
  chrome_options = Selenium::WebDriver::Chrome::Options.new.tap do |o|
    o.add_argument '--enable-features=NetworkService,NetworkServiceInProcess'
    o.add_argument '--guest'
    o.add_argument '--headless' unless ENV['SHOW_BROWSER']
    o.add_argument '--no-sandbox'
    o.add_argument '--window-size=1920,1200'
  end
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: chrome_options)
end

Capybara.default_driver = :selenium
Capybara.current_session.driver.reset!
Capybara.default_host = ENV['ACCEPTANCE_TESTS_EDITOR_APP']
Capybara.app_host = ENV['ACCEPTANCE_TESTS_EDITOR_APP']
Capybara.run_server = false
Capybara.default_max_wait_time = 15
