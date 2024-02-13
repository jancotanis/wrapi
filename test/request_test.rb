require 'test_helper'
require 'logger'

REQUEST_LOGGER = 'request_test.log'
File.delete(REQUEST_LOGGER) if File.exist?(REQUEST_LOGGER)

module RequestMockAPI
  extend WrAPI::Configuration
  extend WrAPI::RespondTo

  def self.client(options = {})
    WrAPI::API.new({ logger: Logger.new(REQUEST_LOGGER) }.merge(options))
  end
end

describe 'request' do

  it '#1 check get.request' do
    url = 'http://ip.jsontest.com/'
    c = RequestMockAPI.client({ format: :json, endpoint: url })
    calls = 0
    c.get( '/' ) do |request|
      calls += 1
      assert value(request.http_method).must_equal(:get), ".method must equal"
      assert_nil request.path, ".path is nil"
      assert_nil request.body, ".body is nil"
      assert request.headers['Accept']["application/#{c.format}"], ".accept must be set and have 'app/format'"
    end
    assert value(calls).must_equal(1), "block is called" 
  end
  it '#2 check post.request' do
    url = 'http://ip.jsontest.com/'
    c = RequestMockAPI.client({ format: :json, endpoint: url })
    
    calls = 0
    c.post( '/' ) do |request|
      calls += 1
      assert value(request.http_method).must_equal(:post), ".method must equal"
      assert_nil request.path, ".path is nil"
      assert_nil request.body, ".body is nil"
      assert request.headers['Accept']["application/#{c.format}"], ".accept must be set and have 'app/format'"
    end
    assert value(calls).must_equal(1), "block is called" 
  end
  it '#3 check paged request' do
    url = 'http://ip.jsontest.com/'
    c = RequestMockAPI.client({ format: :json, endpoint: url })
    
    calls = 0
    c.get_paged( '/' ) do |data|
      calls += 1
      assert value(data.class).must_equal WrAPI::Request::Entity, 'must be wrapi entity'
      refute_nil data.ip
    end
    assert value(calls).must_equal(1), 'block is called'

    calls = 0
    c.get_paged( '/', {}, ->(req){ req['my-header']='wrapi'; calls += 1 } ) do |data|
      calls += 1
      assert value(data.class).must_equal WrAPI::Request::Entity, 'must be wrapi entity'
      refute_nil data.ip
      # cannot test header vcalue, please check log file
      # assert value(request['my-header']).must_equal('wrapi'), '.header must be set'
    end
    assert value(calls).must_equal(2), 'block is called'
    count = 0
    File.open(REQUEST_LOGGER).each_line do |line| 
      count += 1 if line.include?('my-header: "wrapi"')
    end
    assert value(count).must_equal(1), 'header found'
  end

end
