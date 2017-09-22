require File.expand_path("../../lib/mock_geocoder", __FILE__)
require File.expand_path("../support/features/session_helpers", __FILE__)

RSpec.configure do |config|
  config.include(MockGeocoder)
  config.include Features::SessionHelpers, type: :feature
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # config.before(:type => :feature) do
  #   resize_window(1440,900)
    # page.driver.browser.manage.window.resize_to(1440, 900)
  # end

end
