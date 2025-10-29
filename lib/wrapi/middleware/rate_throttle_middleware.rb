# frozen_string_literal: true

require 'faraday'

module WrAPI
  # A Faraday middleware for rate limiting requests.
  #
  # This middleware ensures that the number of requests made through a Faraday connection
  # does not exceed a specified limit within a given time period.
  #
  # @example Add middleware to a Faraday connection
  #   connection = Faraday.new(url: 'https://api.example.com') do |faraday|
  #     faraday.use RateThrottleMiddleware, limit: 300, period: 60
  #     faraday.adapter Faraday.default_adapter
  #   end
  #
  # @see https://github.com/lostisland/faraday Faraday Documentation
  #
  class RateThrottleMiddleware < Faraday::Middleware
    # Initializes the RateThrottleMiddleware.
    #
    # @param app [#call] The next middleware or the actual Faraday adapter.
    # @param limit [Integer] The maximum number of requests allowed within the specified period. Default is 300.
    # @param period [Integer] The time period in seconds over which the limit applies. Default is 60 seconds.
    #
    # @example
    #   middleware = RateThrottleMiddleware.new(app, limit: 300, period: 60)
    #
    def initialize(app, limit: 300, period: 60)
      super(app)
      @limit = limit
      @period = period
      @requests = []
      @mutex = Mutex.new
      @condition = ConditionVariable.new
    end

    def call(env)
      throttle_request
      @app.call(env)
    end

    private

    def throttle_request
      @mutex.synchronize do
        now = Time.now.to_f
        remove_expired_requests(now)

        rate_limited(now)

        # Record the new request
        @requests.push(Time.now.to_f)
        @condition.broadcast
      end
    end

    def remove_expired_requests(now)
      # Clear requests older than the rate limit period
      @requests.pop while !@requests.empty? && @requests[0] < (now - @period)
    end

    def rate_limited(now)
      # Wait if the request limit is reached
      while @requests.size >= @limit
        sleep_time = @requests[0] + @period - now
        @condition.wait(@mutex, sleep_time) if sleep_time.positive?
        remove_expired_requests(Time.now.to_f)
      end
    end
  end
end
