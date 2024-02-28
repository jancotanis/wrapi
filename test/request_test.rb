require 'test_helper'
require 'logger'

REQUEST_LOGGER = 'request_test.log'
File.delete(REQUEST_LOGGER) if File.exist?(REQUEST_LOGGER)

module RequestMockAPI
  extend WrAPI::Configuration
  extend WrAPI::RespondTo

  def self.client(options = {})
    WrAPI.reset
    WrAPI::API.new({ logger: Logger.new(REQUEST_LOGGER) }.merge(options))
  end
  
  def self.ipjsontest
    WebMock.disable_net_connect!
    url = 'http://ip.jsontest.com/'
    WebMock.stub_request(:any, url).
        with(
          headers: {
            'Accept'=>'application/json; charset=utf-8',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3'
          }).
        to_return(status: 200, body: '{"ip": "145.131.192.220"}', headers: { 'Content-Type' => 'application/json' })
    url
  end
  def self.array_json_test(body = nil)
    url = 'http://array.jsontest.com/'
    with = { headers: {
            'Accept'=>'application/json; charset=utf-8',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3'
          }}
    to_return = {status: 200, headers: { 'Content-Type' => 'application/json' }}
    if body
      with[:body] = body
      to_return[:body] = body.to_json
    end
    WebMock.stub_request(:any, url).
        with(with).
        to_return(to_return)
    url
  end
end

describe 'request' do
  it '#1 check get.request' do
    url = RequestMockAPI.ipjsontest
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
    url = RequestMockAPI.ipjsontest
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
    url = RequestMockAPI.ipjsontest
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
      # cannot test header value, please check log file
      # assert value(request['my-header']).must_equal('wrapi'), '.header must be set'
    end
    assert value(calls).must_equal(2), 'block is called'
    count = 0
    File.open(REQUEST_LOGGER).each_line do |line| 
      count += 1 if line.include?('my-header: "wrapi"')
    end
    assert value(count).must_equal(1), 'header found'
    # test all in one go
    data = c.get_paged( '/' )
    assert value(data.class).must_equal Array, 'must be an array'
  end
  it '#4 post/put/delete request' do
    arr = [{ a: 'a' },{ b: 'b' }]
    url = RequestMockAPI.array_json_test(arr)
    c = RequestMockAPI.client({ format: :json, endpoint: url })

    e = c.post('', arr, false )
    assert value(e.class).must_equal Array, 'is array result'
    assert value(e.first.a).must_equal arr.first[:a], 'check first array result'

    e = c.put('', arr, false )
    assert value(e.class).must_equal Array, 'is array result'
    assert value(e.first.a).must_equal arr.first[:a], 'check first array result'


    RequestMockAPI.array_json_test()
    data = c.get_paged('/')
    assert value(data.class).must_equal(Array), 'must be an array'
    assert value(data.count).must_equal(0), 'must be an array with 0 entries (cannot pass array as get parameter)'

    assert_nil c.get('/'), "get returning nil"
    assert_nil c.delete(''), "delete returning nil"
    
  end
  it '#5 non json' do
    c = RequestMockAPI.client({ endpoint: url })
    assert c.is_json?, 'should be json by default'
  end
end
