require 'test_helper'

CON_LOGGER = 'connection_test.log'
File.delete(CON_LOGGER) if File.exist?(CON_LOGGER)

module ConnectionMockAPI
  extend WrAPI::Configuration
  extend WrAPI::RespondTo

  def self.client(options = {})
    WebMock.allow_net_connect!
    WrAPI::API.new({ logger: Logger.new(CON_LOGGER) }.merge(options))
  end
end

describe 'connection' do
  it '#1 no endpoint' do
    ConnectionMockAPI.user_agent = "ConnectionMocking all the time"
    ConnectionMockAPI.reset
    c = ConnectionMockAPI.client
    assert_raises ArgumentError do
      c.get( '/' )
    end
  rescue
    puts c.inspect
  end
  it '#1 valid endpoint' do
    c = ConnectionMockAPI.client({ format: 'html', endpoint: 'https://www.google.com' })
    c.get( '/' )
  rescue ArgumentError 
    # should not raise endpoint argument exception
    flunk 'Unexpected ArgumentError raised'
  end
  it '#1 valid endpoint, check content type' do
    c = ConnectionMockAPI.client({ format: 'html', endpoint: 'https://www.google.com' })
    assert_raises ArgumentError do
      c.get_paged( '/' )
    end
    c = ConnectionMockAPI.client({ format: :json, endpoint: 'http://ip.jsontest.com/' })
    c.get_paged( '/' )
  rescue ArgumentError 
    # should not raise endpoint argument exception
    flunk 'Unexpected ArgumentError raised'
  end

end
