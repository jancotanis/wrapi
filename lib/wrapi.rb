# frozen_string_literal: true

require File.expand_path('wrapi/version', __dir__)
require File.expand_path('wrapi/pagination', __dir__)
require File.expand_path('wrapi/configuration', __dir__)
require File.expand_path('wrapi/connection', __dir__)
require File.expand_path('wrapi/api', __dir__)
require File.expand_path('wrapi/entity', __dir__)
require File.expand_path('wrapi/request', __dir__)
require File.expand_path('wrapi/respond_to', __dir__)
require File.expand_path('wrapi/authentication', __dir__)

# WrAPI module provides a structure for creating API wrappers.
# It extends RespondTo and Configuration modules to include their functionalities.
#
# Methods:
# - self.client(_options = {}): Abstract method that should be overridden in the including class.
#   Raises NotImplementedError if not implemented.
# - self.reset: Resets the configuration to defaults and sets the user agent string.
module WrAPI
  extend RespondTo
  extend Configuration

  # Abstract method should be overridden
  #
  # @return client
  def self.client(_options = {})
    raise NotImplementedError, 'Abstract method self.client must implemented when including ResponTo'
  end

  # set/override defaults
  def self.reset
    super
    self.user_agent = "Ruby API wrapper #{WrAPI::VERSION}"
  end
end
