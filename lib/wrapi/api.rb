# frozen_string_literal: true

require File.expand_path('configuration', __dir__)
require File.expand_path('connection', __dir__)
require File.expand_path('request', __dir__)
require File.expand_path('authentication', __dir__)

module WrAPI
  # The API class is responsible for managing the configuration and connections
  # for the WrAPI library. It includes modules for handling connections, requests,
  # and authentication.
  #
  # @attr_accessor [Hash] options Configuration options for the API instance.
  #
  # @example Creating a new API instance
  #   api = WrAPI::API.new(api_key: 'your_api_key')
  #
  # @example Accessing the configuration
  #   config = api.config
  #   puts config[:api_key]
  #
  # @see WrAPI::Connection
  # @see WrAPI::Request
  # @see WrAPI::Authentication
  class API
    attr_accessor(*WrAPI::Configuration::VALID_OPTIONS_KEYS)

    # Initializes a new API object with the given options.
    #
    # @param options [Hash] A hash of options to configure the API object.
    #   The options are merged with the default options from `WrAPI.options`.
    #
    # @option options [String] :api_key The API key for authentication.
    # @option options [String] :api_secret The API secret for authentication.
    # @option options [String] :endpoint The API endpoint URL.
    # @option options [String] :user_agent The User-Agent header for HTTP requests.
    # @option options [Integer] :timeout The timeout for HTTP requests.
    # @option options [Integer] :open_timeout The open timeout for HTTP requests.
    #
    # @return [WrAPI::API] A new API object configured with the given options.
    def initialize(options = {})
      options = WrAPI.options.merge(options)
      WrAPI::Configuration::VALID_OPTIONS_KEYS.each do |key|
        send("#{key}=", options[key])
      end
    end

    # Returns a hash of configuration options and their values.
    # Iterates over each valid configuration key defined in WrAPI::Configuration::VALID_OPTIONS_KEYS,
    # and assigns the corresponding value by calling the method with the same name as the key.
    #
    # @return [Hash] A hash containing the configuration options and their values.
    def config
      conf = {}
      WrAPI::Configuration::VALID_OPTIONS_KEYS.each do |key|
        conf[key] = send key
      end
      conf
    end

    include WrAPI::Connection
    include WrAPI::Request
    include WrAPI::Authentication
  end
end
