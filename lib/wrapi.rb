require File.expand_path('wrapi/authentication', __dir__)
require File.expand_path('wrapi/connection', __dir__)
require File.expand_path('wrapi/configuration', __dir__)
require File.expand_path('wrapi/api', __dir__)
require File.expand_path('wrapi/request', __dir__)
require File.expand_path('wrapi/entity', __dir__)
require File.expand_path('wrapi/respond_to', __dir__)
require File.expand_path('wrapi/version', __dir__)

module WrAPI
  extend RespondTo
  extend Configuration

  # Abstract method should be overridden
  #
  # @return client
  def self.client(options = {})
    raise NotImplementedError, 'Abstract method self.client must implemented when including ResponTo'
  end

  # set/override defaults
  def self.reset
    super
    self.user_agent = "Ruby API wrapper #{WrAPI::VERSION}".freeze
  end
end
