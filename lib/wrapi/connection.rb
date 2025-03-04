# frozen_string_literal: true

require 'faraday'

module WrAPI
  # @private
  # The Connection module provides methods to establish and configure a Faraday connection.
  # It includes private methods to set up options, authorization, headers, and logging for the connection.
  # By default
  # - Bearer authorization is access_token is not nil override with @setup_authorization
  # - Headers setup for client-id and client-secret when client_id and client_secret are not nil @setup_headers
  #
  # Methods:
  # - connection: Establishes a Faraday connection with the configured options, authorization, headers, and logging.
  # - setup_options: Sets up the options for the Faraday connection, including headers and URL.
  # - setup_authorization: Configures the authorization header for the Faraday connection.
  # - setup_headers: Configures additional headers for the Faraday connection.
  # - setup_logger_filtering: Sets up logging and filtering for sensitive information in the Faraday connection.
  module Connection
    private

    # Establishes a Faraday connection with the specified options and configurations.
    #
    # @raise [ArgumentError] if the endpoint option is not defined.
    # @return [Faraday::Connection] a configured Faraday connection.
    #
    # The connection is configured with the following:
    # - Raises errors for HTTP responses.
    # - Uses the default Faraday adapter.
    # - Sets up authorization and headers.
    # - Parses JSON responses.
    # - Uses URL-encoded requests.
    # - Optionally sets up logger filtering if a logger is provided.
    def connection
      raise ArgumentError, 'Option for endpoint is not defined' unless endpoint

      options = setup_options
      Faraday::Connection.new(options) do |connection|
        connection.use Faraday::Response::RaiseError
        connection.adapter Faraday.default_adapter
        setup_authorization(connection)
        setup_headers(connection)
        connection.response :json, content_type: /\bjson$/
        connection.use Faraday::Request::UrlEncoded

        setup_logger_filtering(connection, logger) if logger
      end
    end

    # Sets up the options for the connection. acts as a callback method to
    # setup api authorization
    #
    # @return [Hash] A hash containing the headers and URL for the connection,
    #   merged with any additional connection options.
    # @option options [Hash] :headers The headers for the connection, including:
    #   - 'Accept' [String]: The content type to accept, based on the format.
    #   - 'User-Agent' [String]: The user agent string.
    # @option options [String] :url The endpoint URL for the connection.
    def setup_options
      {
        headers: {
          'Accept': "application/#{format}; charset=utf-8",
          'User-Agent': user_agent
        },
        url: endpoint
      }.merge(connection_options || {})
    end

    # Sets up the authorization header for the given connection.
    # override  to setup your own header for api authorization
    #
    # @param connection [Object] The connection object to which the authorization header will be added.
    # @return [void]
    # @note The authorization header will only be set if the access_token is present.
    def setup_authorization(connection)
      connection.headers['Authorization'] = "Bearer #{access_token}" if access_token
    end

    # Sets up the headers for the given connection. Override to set own headers.
    #
    # @param connection [Object] The connection object to set headers on.
    # @option connection.headers [String] 'client-id' The client ID, if available.
    # @option connection.headers [String] 'client-secret' The client secret, if available.
    #
    # @return [void]
    def setup_headers(connection)
      connection.headers['client-id'] = client_id if client_id
      connection.headers['client-secret'] = client_secret if client_secret
    end

    # Sets up logger filtering for the given connection.
    #
    # This method configures the logger to filter sensitive information from the
    # connection's response. It filters out passwords, access tokens, client secrets,
    # and authorization headers from the logs.
    #
    # @param connection [Faraday::Connection] The connection object to configure the logger for.
    # @param logger [Logger] The logger instance to use for logging the connection's responses.
    #
    # @example
    #   setup_logger_filtering(connection, logger)
    #
    # @note This method assumes that the connection object is a Faraday connection.
    def setup_logger_filtering(connection, logger)
      connection.response :logger, logger, { headers: true, bodies: true } do |log|
        # Filter sensitive information from JSON content, such as passwords and access tokens.
        log.filter(/("password":")(.+?)(".*)/, '\1[REMOVED]\3')
        log.filter(/("[Aa]ccess_?[Tt]oken":")(.+?)(".*)/, '\1[REMOVED]\3')
        # filter sensitive header content such as client secrets and authorization headers
        log.filter(/(client[-_]secret[:=].)([^&]+)/, '\1[REMOVED]')
        log.filter(/(Authorization:.)([^&]+)/, '\1[REMOVED]')
      end
    end
  end
end
