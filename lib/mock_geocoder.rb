# In spec_helper:
# RSpec.configure do |config|
#   ...
#   config.include(MockGeocoder)
# end
#
# In your tests:
# it 'mock geocoding' do
#   # You may pass additional params to override defaults
#   # (i.e. :coordinates => [10, 20])
#   mock_geocoding!
#   address = Factory(:address)
#   address.lat.should eq(1)
#   address.lng.should eq(2)
# end

require 'geocoder/results/base'

module MockGeocoder
  def self.included(base)
    base.before :each do
      allow(::Geocoder).to receive(:search).and_raise(
        RuntimeError.new 'Use "mock_geocoding!" method in your tests.')
    end
  end

  def mock_geocoding!(options = {})
    options.reverse_merge!(
      address: 'Address',
      coordinates: [1, 2],
      state: 'State',
      state_code: 'State Code',
      country: 'Country',
      country_code: 'Country code'
    )

    MockResult.new.tap do |result|
      options.each do |prop, val|
        allow(result).to receive(prop).and_return(val)
      end
      allow(Geocoder).to receive(:search).and_return([result])
    end
  end

  class MockResult < ::Geocoder::Result::Base
    def initialize(data = [])
      super(data)
    end
  end
end