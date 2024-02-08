require 'test_helper'
require 'logger'

module ConfigMockAPI
  extend WrAPI::Configuration
  extend WrAPI::RespondTo

  def self.client(options = {})
    WrAPI::API.new(options)
  end
end


describe 'config' do
  it '#1 defaults/reset' do
    WrAPI.reset
    assert_nil WrAPI.endpoint, '.endpoint empty'
    assert value(WrAPI.format).must_equal WrAPI::Configuration::DEFAULT_FORMAT, '.format'
    assert value(WrAPI.user_agent).must_equal WrAPI::Configuration::DEFAULT_USER_AGENT, '.user_agent'
    assert WrAPI.logger.nil?, '.logger'
    WrAPI.endpoint = 'http://helloworld.com'
    assert value(WrAPI.endpoint).must_equal 'http://helloworld.com', '.endpoint='
    WrAPI.reset
    assert_nil WrAPI.endpoint, 'reset, check .endpoint'
  end
  it '#2 configure block' do
    logger = Logger.new(IO::NULL)
    WrAPI.configure do |config|
      config.access_token = 'YOUR_ACCESS_TOKEN'
      config.client_id = 'YOUR_CLIENT_ID'
      config.client_secret = 'YOUR_CLIENT_SECRET'
      config.endpoint = 'http://api.abc.com'
      config.format = 'xml'
      config.user_agent = 'Custom User Agent'
      config.logger = logger
    end
    assert value(WrAPI.access_token).must_equal 'YOUR_ACCESS_TOKEN', '.access_token='
    assert value(WrAPI.client_id).must_equal 'YOUR_CLIENT_ID', '.client_id='
    assert value(WrAPI.client_secret).must_equal 'YOUR_CLIENT_SECRET', '.client_secret='
    assert value(WrAPI.endpoint).must_equal 'http://api.abc.com', '.format='
    assert value(WrAPI.format).must_equal 'xml', '.format='
    assert value(WrAPI.user_agent).must_equal 'Custom User Agent', '.user_agent='
    assert value(WrAPI.logger).must_equal logger, '.logger='
  end
  it '#3 configure all' do
    WrAPI::Configuration::VALID_OPTIONS_KEYS.each do |key|
      WrAPI.configure do |config|
        config.send("#{key}=", key)
        assert value(WrAPI.send(key)).must_equal key, '.{key}=key'
      end
    end
  end
  it '#4 client hash' do
    options = {
      access_token: 'YOUR_ACCESS_TOKEN',
      client_id: 'YOUR_CLIENT_ID',
      client_secret: 'YOUR_CLIENT_SECRET',
      endpoint: 'http://coas.com',
      format: 'xml',
      user_agent: 'Custom User Agent',
      logger: true
    }
    c = ConfigMockAPI.client(options)
    assert value(c.access_token).must_equal 'YOUR_ACCESS_TOKEN', '.access_token='
    assert value(c.client_id).must_equal 'YOUR_CLIENT_ID', '.client_id='
    assert value(c.client_secret).must_equal 'YOUR_CLIENT_SECRET', '.client_secret='
    assert value(c.format).must_equal 'xml', '.format='
    assert value(c.user_agent).must_equal 'Custom User Agent', '.user_agent='
    assert value(c.logger).must_equal true, '.logger='
  end
  it '#5 client' do
    assert_raises NotImplementedError do
      WrAPI.client
    end
    assert value(ConfigMockAPI.client.class).must_equal WrAPI::API, '.client'
  end
end
