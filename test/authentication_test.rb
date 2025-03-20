require 'test_helper'

AUTH_LOGGER = 'auth_test.log'
File.delete(AUTH_LOGGER) if File.exist?(AUTH_LOGGER)

module AuthMockAPI
  extend WrAPI::Configuration
  extend WrAPI::RespondTo
  URL = 'http://auth.api/'
  
  def self.mock(path, body = {}, format=:json)
    with = {
      headers: {
        'Accept'=>"application/#{format}; charset=utf-8",
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3'
      } }
    with[:body] = body if body
    WebMock.stub_request(:post, URL+path).
        with(with).
        to_return(status: 200, body: '{"accessToken":"access","tokenType":"Bearer","expiresIn":123456789,"refreshToken":"refresh"}', headers: { 'Content-Type' => "application/#{format}" })
  end
  
  def self.mock_client(path, options = {}, body = {}, format = :json)
    self.mock(path, body, format)
    WrAPI.reset
    WrAPI::API.new({ format: format, endpoint: URL, logger: Logger.new(AUTH_LOGGER) }.merge(options))
  end
end

describe 'authentication' do
  it '#1 auth, check api_auth' do
    c = AuthMockAPI.mock_client('1')
    c.api_auth('1')

    assert value(c.access_token).must_equal('access')
    assert value(c.refresh_token).must_equal('refresh')
    assert value(c.token_type).must_equal('Bearer')
    assert value(c.token_expires).must_equal(123456789)
  end
  it '#2 auth, check api_auth username/password' do
    options = { username: 'username', password: 'password' }
    c = AuthMockAPI.mock_client('2', options, options)
    c.api_auth('2')

    assert value(c.access_token).must_equal('access')
    assert value(c.refresh_token).must_equal('refresh')
    assert value(c.token_type).must_equal('Bearer')
    assert value(c.token_expires).must_equal(123456789)
  end
  it '#3 auth, check api_auth username/password' do
    token = 'refresh-token'
    c = AuthMockAPI.mock_client('3', {}, { refreshToken: token })
    c.api_refresh('3', token)

    assert value(c.access_token).must_equal('access')
    assert value(c.refresh_token).must_equal('refresh')
    assert value(c.token_type).must_equal('Bearer')
    assert value(c.token_expires).must_equal(123456789)
  end
  it '#4 log filtering' do
    # credentials setup
    credentials = { username: 'username', password: 'password' }
    # auth using json/form auth to check logformats
    [:json, 'x-www-form-urlencoded'].each do |format|
      path = "4/#{format}"
      c = AuthMockAPI.mock_client(path, {}, credentials, format)
      c.api_auth(path, credentials)
    end

    # read logfile and check if password is masked
    log_content = File.read(AUTH_LOGGER)
    assert log_content['request: {"username":"username","password":"[REMOVED]"}']
    assert log_content['request: username=username&password=[REMOVED]']
    assert log_content['"accessToken":"[REMOVED]"']
  end
end
