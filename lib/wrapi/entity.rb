require 'json'

module WrAPI
  # Defines HTTP request methods
  module Request
    class Entity
      # factory method to create entity or array of entities
      def self.create(attr)
        if attr.is_a? Array
          Entity.entify(attr)
        else
          Entity.new(attr) if attr
        end
      end

      def initialize(attr)
        case attr
        when Hash
          @attributes = attr.clone.transform_keys(&:to_s)
        else
          @attributes = attr.clone
        end
      end
      
      def attributes
        @attributes || {}
      end

      def attributes= val
        @attributes = val || {}
      end

      def method_missing(method_sym, *arguments, &block)
        # assignment
        assignment = method_sym[/.*(?==\z)/m]
        if assignment
          raise ArgumentError, "wrong number of arguments (given #{arguments.length}, expected 1)", caller(1) unless arguments.length == 1

          @attributes[assignment] = arguments[0]
        elsif @attributes.include? method_sym.to_s
          accessor(method_sym.to_s)
        else
          # delegate to hash
          @attributes.send(method_sym, *arguments, &block)
        end
      end

      def respond_to?(method_sym, include_private = false)
        @attributes ||= {}
        if @attributes.include? method_sym.to_s
          true
        else
          @attributes.respond_to?(method_sym, include_private)
        end
      end

      def to_json(options = {})
        @attributes.to_json
      end

      def accessor(method)
        case @attributes[method]
        when Hash
          @attributes[method] = self.class.new(@attributes[method])
        when Array
          # make deep copy
          @attributes[method] = Entity.entify(@attributes[method])
        else
          @attributes[method]
        end
      end
      
      def clone
        c = super
        c.attributes = @attributes.clone
        c
      end

      def ==(other)
        (self.class == other.class) && (self.attributes.eql? other.attributes)
      end
      alias eql? ==

      def self.entify(a)
        if ( a.count > 0 ) && ( a.first.is_a? Hash )
          a.dup.map do |item|
            #item.is_a?(Hash) ? self.class.new(item) : item
            Entity.create(item)
          end
        else
          a
        end
      end
    end
  end
end
