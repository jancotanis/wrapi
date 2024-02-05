require 'json'

module WrAPI
  # Defines HTTP request methods
  module Request
    class Entity
      attr_reader :attributes

      def initialize(attributes)
        @_raw = attributes

        case attributes
        when Hash
          @attributes = attributes.clone.transform_keys(&:to_s)
        when Array
          # make deep copy
          @attributes = entify(attributes)
        else
          @attributes = attributes.clone
        end
      end

      def method_missing(method_sym, *arguments, &block)
        len = arguments.length
        # assignment
        if (method = method_sym[/.*(?==\z)/m])
          raise! ArgumentError, "wrong number of arguments (given #{len}, expected 1)", caller(1) unless len == 1

          @attributes[method] = arguments[0]
        elsif @attributes.include? method_sym.to_s
          r = @attributes[method_sym.to_s]
          case r
          when Hash
            @attributes[method_sym.to_s] = self.class.new(r)
          when Array
            # make deep copy
            @attributes[method_sym.to_s] = r = entify(r)
            r
          else
            r
          end
        else
          @attributes.send(method_sym, *arguments, &block)
        end
      end

      def respond_to?(method_sym, include_private = false)
        if @attributes.include? method_sym.to_s
          true
        else
          @attributes.respond_to?(method_sym, include_private)
        end
      end

      def to_json(options = {})
        @_raw.to_json
      end
      
      def entify(a)
        a.map do |item|
          item.is_a?(Hash) ? self.class.new(item) : item
        end
      end
    end
  end
end
