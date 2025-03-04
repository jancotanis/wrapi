# frozen_string_literal: true

module WrAPI
  # Module to delegate methods to the Client
  module RespondTo
    # Delegate method calls to the Client
    #
    # @param method [Symbol] the method name
    # @param args [Array] the arguments passed to the method
    # @param block [Proc] an optional block
    def self.method_missing(method, *args, &block)
      return super unless client.respond_to?(method)

      client.send(method, *args, &block)
    end

    # Checks if the Client responds to a method
    #
    # @param method [Symbol] the method name
    # @param include_all [Boolean] whether to include private methods
    # @return [Boolean] true if the Client responds to the method, false otherwise
    def self.respond_to?(method, include_all = false)
      client.respond_to?(method, include_all) || super
    end
  end
end
