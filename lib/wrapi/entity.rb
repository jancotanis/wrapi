# frozen_string_literal: true

require 'json'

# This module defines the WrAPI namespace which is used to encapsulate all the classes and modules
# related to the WrAPI library. The WrAPI library provides functionality for interacting with APIs.
module WrAPI
  # Defines HTTP request methods
  module Request
    # Entity class to represent and manipulate API data
    class Entity
      # Factory method to create an entity or array of entities
      #
      # @param attr [Hash, Array<Hash>] the attributes to create the entity/entities from
      # @return [Entity, Array<Entity>] the created entity or array of entities
      def self.create(attr)
        if attr.is_a? Array
          Entity.entify(attr)
        elsif attr
          Entity.new(attr)
        end
      end

      # Initializes a new Entity
      #
      # @param attr [Hash] the attributes to initialize the entity with
      def initialize(attr)
        case attr
        when Hash
          @attributes = attr.clone.transform_keys(&:to_s)
        else
          @attributes = attr.clone
        end
      end
      
      # Returns the attributes of the entity
      #
      # @return [Hash] the attributes of the entity
      def attributes
        @attributes || {}
      end

      # Sets the attributes of the entity
      #
      # @param val [Hash] the new attributes of the entity
      def attributes=(val)
        @attributes = val || {}
      end

      # Handles dynamic method calls for attribute access and assignment
      #
      # @param method_sym [Symbol] the method name
      # @param arguments [Array] the arguments passed to the method
      # @param block [Proc] an optional block
      def method_missing(method_sym, *arguments, &block)
        # assignment
        method = method_sym.to_s
        assignment = method_sym[/.*(?==\z)/m]
        if assignment
          raise ArgumentError, "wrong number of arguments (given #{arguments.length}, expected 1)", caller(1) unless arguments.length == 1

          @attributes[assignment] = arguments[0]
        elsif @attributes.include? method
          accessor(method)
        else
          # delegate to hash
          @attributes.send(method_sym, *arguments, &block)
        end
      end

      # Checks if the entity responds to a method
      #
      # @param method_sym [Symbol] the method name
      # @param include_private [Boolean] whether to include private methods
      # @return [Boolean] true if the entity responds to the method, false otherwise
      def respond_to?(method_sym, include_private = false)
        @attributes ||= {}
        if @attributes.include? method_sym.to_s
          true
        else
          @attributes.respond_to?(method_sym, include_private)
        end
      end

      # Converts the entity to a JSON string
      #
      # @param options [Hash] options for JSON generation
      # @return [String] the JSON representation of the entity
      def to_json(_options = {})
        @attributes.to_json
      end

      # Accesses an attribute, converting it to an Entity if it is a Hash or Array
      #
      # @param method [String] the attribute name
      # @return [Object] the attribute value
      def accessor(method)
        attribute = @attributes[method]
        case attribute
        when Hash
          @attributes[method] = self.class.new(attribute)
        when Array
          # make deep copy
          @attributes[method] = Entity.entify(attribute)
        else
          attribute
        end
      end

      # Clones the entity
      #
      # @return [Entity] the cloned entity
      def clone
        c = super
        c.attributes = @attributes.clone
        c
      end

      # Checks if two entities are equal
      #
      # @param other [Entity] the other entity to compare with
      # @return [Boolean] true if the entities are equal, false otherwise
      def ==(other)
        (self.class == other.class) && (self.attributes.eql? other.attributes)
      end
      alias eql? ==

      # Converts an array of hashes to an array of entities
      #
      # @param attribute [Array<Hash>] the array of hashes
      # @return [Array<Entity>] the array of entities
      def self.entify(attribute)
        if (attribute.count > 0) && (attribute.first.is_a? Hash)
          attribute.dup.map do |item|
            #item.is_a?(Hash) ? self.class.new(item) : item
            Entity.create(item)
          end
        else
          attribute
        end
      end
    end
  end
end
