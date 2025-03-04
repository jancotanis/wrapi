# frozen_string_literal: true

module WrAPI
  # Deals with authentication flow and stores it within global configuration
  # following attributes should be available:
  #  username
  #  password
  #  access_token
  #  token_type
  #  refresh_token
  #  token_expires
  module Authentication
    # Authenticates the API request by merging the provided options with the API access token parameters,
    # sending a POST request to the specified path, and processing the response to extract the access token.
    #
    # @param path [String] the API endpoint path to which the authentication request is sent.
    # @param options [Hash] additional parameters to be merged with the API access token parameters.
    # @return [String] the processed access token extracted from the response body.
    def api_auth(path, options = {})
      params = api_access_token_params.merge(options)
      response = post(path, params)
      # return access_token
      api_process_token(response.body)
    end

    # Refreshes the API token by making a POST request to the specified path with the given refresh token.
    #
    # @param path [String] the endpoint path to send the refresh request to.
    # @param token [String] the refresh token to be used for obtaining a new access token.
    # @return [String] the new access token obtained from the response.
    def api_refresh(path, token)
      params = { refreshToken: token }

      response = post(path, params)
      # return access_token
      api_process_token(response.body)
    end

    private

    # Returns a hash containing the API access token parameters.
    # Override this when passing different parameters
    #
    # @return [Hash] a hash with the following keys:
    #   - :username [String] the username for API authentication
    #   - :password [String] the password for API authentication
    def api_access_token_params
      {
        username: username,
        password: password
      }
    end

    # Processes the API response to extract and set the authentication tokens.
    # Raises an ArgumentError if the response is nil.
    # Override this when passing different parameters
    #
    # @param response [Hash] The response from the API containing authentication tokens.
    # @return [String] The access token extracted from the response.
    # @raise [ArgumentError] If the response is nil.
    # @raise [StandardError] If the access token is not found or is empty.
    def api_process_token(response)
      raise ArgumentError.new("Response cannot be nil") if response.nil?

      token = self.access_token = response['accessToken']
      self.token_type        = response['tokenType']
      self.refresh_token     = response['refreshToken']
      self.token_expires     = response['expiresIn']
      raise StandardError.new("Could not find valid accessToken; response #{response}") if token.to_s.empty?

      token
    end
  end
end
