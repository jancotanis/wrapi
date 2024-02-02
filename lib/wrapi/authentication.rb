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
    # Authorize to the portal and return access_token
    def api_auth(path, options = {})
      params = api_access_token_params.merge(options)
      response = post(path, params)
      # return access_token
      api_process_token(response.body)
    end

    # Return an access token from authorization
    def api_refresh(path, token)
      params = { refreshToken: token }

      response = post(path, params)
      # return access_token
      api_process_token(response.body)
    end

  private

    def api_access_token_params
      {
        username: username,
        password: password
      }
    end

    def api_process_token(response)
      at = self.access_token = response['accessToken']
      self.token_type        = response['tokenType']
      self.refresh_token     = response['refreshToken']
      self.token_expires     = response['expiresIn']
      raise StandardError.new 'Could not find valid accessToken; response ' + response.to_s if at.nil? || at.empty?

      at
    end
  end
end
