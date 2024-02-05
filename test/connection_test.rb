require 'test_helper'

module MockAPI
  extend WrAPI::Configuration
  extend WrAPI::RespondTo

  def self.client(options = {})
    WrAPI::API.new(options)
  end
end

describe 'connection' do
  it '#1 no endpoint' do
    c = MockAPI.client
    assert_raises ArgumentError do
      c.get( '/' )
    end
  end
  it '#1 valid endpoint' do
    c = MockAPI.client({ format: 'html', endpoint: 'https://www.google.com' })
    c.get( '/' )
  rescue ArgumentError 
    # should not raise endpoint argument exception
    flunk 'Unexpected ArgumentError raised'
  end

end
