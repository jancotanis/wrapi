require 'test_helper'

CON_LOGGER = 'connection_test.log'
File.delete(CON_LOGGER) if File.exist?(CON_LOGGER)

module ConnectionMockAPI
  extend WrAPI::Configuration
  extend WrAPI::RespondTo

  def self.client(options = {})
    WebMock.allow_net_connect!
    c = WrAPI::API.new({ logger: Logger.new(CON_LOGGER) }.merge(options))
    # create public connection
    class << c
      def conn
        connection
      end
    end
    c
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
  it '#2 valid endpoint' do
    c = ConnectionMockAPI.client({ format: 'html', endpoint: 'https://www.google.com' })
    c.get('/')
  rescue ArgumentError 
    # should not raise endpoint argument exception
    flunk 'Unexpected ArgumentError raised'
  end
  it '#3 valid endpoint, check content type' do
    c = ConnectionMockAPI.client({ format: 'html', endpoint: 'https://www.google.com' })
    assert_raises ArgumentError do
      c.get_paged('/')
    end
    c = ConnectionMockAPI.client({ format: :json, endpoint: 'https://jsonplaceholder.typicode.com/todos/1' })
    c.get_paged('/')
  rescue ArgumentError 
    # should not raise endpoint argument exception
    flunk 'Unexpected ArgumentError raised'
  end
  it '#4 check middleware' do
    c = ConnectionMockAPI.client({ format: 'html', endpoint: 'https://www.google.com' })
    
    refute c.conn.builder.handlers.any?{ |m| m.name == WrAPI::RateThrottleMiddleware.to_s}
    c = ConnectionMockAPI.client({ format: 'html', endpoint: 'https://www.google.com', rate_limit: 100, rate_period: 60 })
    assert c.conn.builder.handlers.any?{ |m| m.name == WrAPI::RateThrottleMiddleware.to_s}
  end
  
end
