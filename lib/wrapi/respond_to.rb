
module WrAPI
  module RespondTo

    # Delegate to Client
    def self.method_missing(method, *args, &block)
      return super unless client.respond_to?(method)
      client.send(method, *args, &block)
    end

    # Delegate to Client
    def self.respond_to?(method, include_all = false)
      client.respond_to?(method, include_all) || super
    end
  end
end
