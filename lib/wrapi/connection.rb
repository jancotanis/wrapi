require 'faraday'

module WrAPI
  # Create connection including authorization parameters with default Accept format and User-Agent
  # By default
  # - Bearer authorization is access_token is not nil override with @setup_authorization
  # - Headers setup for client-id and client-secret when client_id and client_secret are not nil @setup_headers
  # @private
  module Connection
    private

    def connection
      raise ArgumentError, "Option for endpoint is not defined" unless endpoint

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

    # callback method to setup api authorization
    def setup_options()
      {
        headers: {
          'Accept': "application/#{format}; charset=utf-8",
          'User-Agent': user_agent
        },
        url: endpoint
      }.merge(connection_options || {})
    end

    # callback method to setup api authorization
    def setup_authorization(connection)
      connection.headers['Authorization'] = "Bearer #{access_token}" if access_token
    end

    # callback method to setup api headers
    def setup_headers(connection)
      connection.headers['client-id'] = client_id if client_id
      connection.headers['client-secret'] = client_secret if client_secret
    end

    # callback method to setup logger
    def setup_logger_filtering(connection, logger)
      connection.response :logger, logger, { headers: true, bodies: true } do |l|
        # filter json content
        l.filter(/("password":")(.+?)(".*)/, '\1[REMOVED]\3')
        l.filter(/("[Aa]ccess_?[Tt]oken":")(.+?)(".*)/, '\1[REMOVED]\3')
        # filter header content
        l.filter(/(client[-_]secret[:=].)([^&]+)/, '\1[REMOVED]')
        l.filter(/(Authorization:.)([^&]+)/, '\1[REMOVED]')
      end
    end
  end
end
