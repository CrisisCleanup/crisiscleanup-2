ENV['RAILS_ENV'] ||= 'test'
#require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/rails'
require 'capybara/rspec'
require 'valid_attribute'
require "selenium/webdriver"

ActiveRecord::Migration.maintain_test_schema!

def resize_window(width, height)
  case Capybara.current_driver
    when :selenium
      # Capybara.current_session.driver.browser.manage.window.resize_to(width, height)
      # page.driver.browser.manage.window.resize_to(width, height)
    when :webkit
      handle = Capybara.current_session.driver.current_window_handle
      Capybara.current_session.driver.resize_window_to(handle, width, height)
    else
      raise NotImplementedError, "resize_window is not supported for #{Capybara.current_driver} driver"
  end
end

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w(headless disable-gpu) }
  )

  Capybara::Selenium::Driver.new app,
    browser: :chrome,
    desired_capabilities: capabilities
end

Capybara.default_driver = :headless_chrome

# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.infer_spec_type_from_file_location!
end
