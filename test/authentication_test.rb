require 'test_helper'

AUTH_LOGGER = 'auth_test.log'
File.delete(AUTH_LOGGER) if File.exist?(AUTH_LOGGER)

module AuthMockAPI
  extend WrAPI::Configuration
  extend WrAPI::RespondTo
  URL = 'http://auth.api/'
  def self.client(options = {})
    WrAPI.reset
    WrAPI::API.new({ format: :json, endpoint: URL, logger: Logger.new(AUTH_LOGGER) }.merge(options))
  end
  
  def self.mock(path, body = {})
    with = {
      headers: {
        'Accept'=>'application/json; charset=utf-8',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent'=>'Ruby API wrapper 0.3.0'
      } }
    with[:body] = body if body
    WebMock.stub_request(:post, URL+path).
        with(with).
        to_return(status: 200, body: '{"accessToken":"access","tokenType":"Bearer","expiresIn":123456789,"refreshToken":"refresh"}', headers: { 'Content-Type' => 'application/json' })
  end
end

describe 'authentication' do
  it '#1 auth, check api_auth' do
    AuthMockAPI.mock('1')
    c = AuthMockAPI.client
    c.api_auth('1')

    assert value(c.access_token).must_equal('access')
    assert value(c.refresh_token).must_equal('refresh')
    assert value(c.token_type).must_equal('Bearer')
    assert value(c.token_expires).must_equal(123456789)
  end
  it '#2 auth, check api_auth username/password' do
    options = { username: 'username', password: 'password' }
    AuthMockAPI.mock('2', options)
    
    c = AuthMockAPI.client(options)
    c.api_auth('2')

    assert value(c.access_token).must_equal('access')
    assert value(c.refresh_token).must_equal('refresh')
    assert value(c.token_type).must_equal('Bearer')
    assert value(c.token_expires).must_equal(123456789)
  end
  it '#2 auth, check api_auth username/password' do

    token = 'refresh-token'
    AuthMockAPI.mock('3', { refreshToken: token })
    
    c = AuthMockAPI.client
    c.api_refresh('3', token)

    assert value(c.access_token).must_equal('access')
    assert value(c.refresh_token).must_equal('refresh')
    assert value(c.token_type).must_equal('Bearer')
    assert value(c.token_expires).must_equal(123456789)
  end
end
