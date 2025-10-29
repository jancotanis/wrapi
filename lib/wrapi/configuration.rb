# frozen_string_literal: true

# 
# This module defines constants and methods related to the configuration of the WrAPI.
# It provides a set of default configuration options and allows these options to be overridden.
# 
# Constants:
# - VALID_OPTIONS_KEYS: An array of valid keys in the options hash when configuring a WrAPI::API.
# - DEFAULT_CONNECTION_OPTIONS: Default connection options (empty hash).
# - DEFAULT_FORMAT: Default response format (:json).
# - DEFAULT_PAGE_SIZE: Default page size for paged responses (500).
# - DEFAULT_USER_AGENT: Default user agent string.
# - DEFAULT_PAGINATION: Default pagination class.
# 
# Attributes:
# - access_token: Access token for authentication.
# - token_type: Type of the token.
# - refresh_token: Token used to refresh the access token.
# - token_expires: Expiration time of the token.
# - client_id: Client ID for authentication.
# - client_secret: Client secret for authentication.
# - connection_options: Options for the connection.
# - username: Username for authentication.
# - password: Password for authentication.
# - endpoint: API endpoint.
# - logger: Logger instance.
# - format: Response format.
# - page_size: Page size for paged responses.
# - user_agent: User agent string.
# - pagination_class: Pagination class.
#
# Methods:
# - self.extended(base): Sets all configuration options to their default values when the module is extended.
# - configure: Allows configuration options to be set in a block.
# - options: Creates a hash of options and their values.
# - reset: Resets all configuration options to their default values.
module WrAPI
  # Defines constants and methods related to configuration
  # If configuration is overridden, please add following methods
  # @see [self.extended(base)] to initialize the Configuration
  # If additional options are added, please overide
  # @see [reset] to initialize variables
  # @see [options] to return the correct set of options
  module Configuration
    # An array of valid keys in the options hash when configuring a {WrAPI::API}
    VALID_OPTIONS_KEYS = [
      :access_token,
      :token_type,
      :refresh_token,
      :token_expires,
      :client_id,
      :client_secret,
      :connection_options,
      :username,
      :password,
      :endpoint,
      :logger,
      :format,
      :page_size,
      :user_agent,
      :pagination_class
    ].freeze

    # By default, don't set any connection options
    DEFAULT_CONNECTION_OPTIONS = {}


    # By default token type used in authorizaion header
    DEFAULT_TOKEN_TYPE = 'Bearer'

    # The response format appended to the path and sent in the 'Accept' header if none is set
    #
    # @note JSON is the only available format at this time
    DEFAULT_FORMAT = :json

    # The page size for paged rest responses
    #
    # @note default JSON is the only available format at this time
    DEFAULT_PAGE_SIZE = 500

    # The user agent that will be sent to the API endpoint if none is set
    DEFAULT_USER_AGENT = "Ruby API wrapper #{WrAPI::VERSION}"

    # DEFAULT_PAGINATION is a constant that sets the default pagination strategy for WrAPI requests.
    # It uses the DefaultPager class from the WrAPI::RequestPagination module.
    DEFAULT_PAGINATION = WrAPI::RequestPagination::DefaultPager

    attr_accessor(*VALID_OPTIONS_KEYS)

    # When this module is extended, set all configuration options to their default values
    def self.extended(base)
      base.reset
    end

    # Convenience method to allow configuration options to be set in a block
    def configure
      yield self
    end

    # Create a hash of options and their values
    def options
      VALID_OPTIONS_KEYS.inject({}) do |option, key|
        option.merge!(key => send(key))
      end
    end

    # Reset all configuration options to defaults
    def reset
      self.access_token       = nil
      self.refresh_token      = nil
      self.token_expires      = nil
      self.client_id          = nil
      self.client_secret      = nil
      self.username           = nil
      self.password           = nil
      self.endpoint           = nil

      self.logger             = nil

      self.token_type         = DEFAULT_TOKEN_TYPE
      self.connection_options = DEFAULT_CONNECTION_OPTIONS
      self.format             = DEFAULT_FORMAT
      self.page_size          = DEFAULT_PAGE_SIZE
      self.user_agent         = DEFAULT_USER_AGENT
      self.pagination_class   = DEFAULT_PAGINATION
    end
  end
end
