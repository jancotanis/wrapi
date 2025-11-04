# test/wr_api/rate_throttle_middleware_test.rb
# frozen_string_literal: true

require 'test_helper'
require 'faraday'

describe WrAPI::RateThrottleMiddleware do
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:connection) do
    Faraday.new do |faraday|
      faraday.use WrAPI::RateThrottleMiddleware, limit: 2, period: 1 # 2 requests per second
      faraday.adapter :test, stubs
    end
  end

  before do
    stubs.get('/test') { [200, {}, 'ok'] }
  end

  it 'allows requests under the limit quickly' do
    start = Time.now
    2.times { connection.get('/test') }
    duration = Time.now - start

    _(duration).must_be :<, 0.5
  end

  it 'throttles requests exceeding the limit' do
    start = Time.now
    3.times { connection.get('/test') }
    duration = Time.now - start

    _(duration).must_be :>=, 1.0
  end

  it 'resets the counter after the period' do
    2.times { connection.get('/test') }
    sleep 1.1
    response = connection.get('/test')

    _(response.body).must_equal 'ok'
  end
end
