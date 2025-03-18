# frozen_string_literal: true

require 'uri'
require 'json'

module WrAPI
  # Defines HTTP request methods
  module Request
    CONTENT_TYPE_HDR = 'Content-Type'.freeze

    # Perform an HTTP GET request and return entity in case format is :json
    #
    # @param path [String] the request path
    # @param options [Hash] the request options
    # @param raw [Boolean] whether to return raw response
    # @return [Entity, String] the response entity or raw response body
    def get(path, options = {}, raw = false)
      response = request(:get, path, options) do |request|
        # inject headers...
        yield(request) if block_given?
      end
      entity_response(response, raw)
    end

    # Perform an HTTP GET request for paged data sets response
    #
    # @param path [String] the request path
    # @param options [Hash] the request options
    # @param request_labda [Proc] an optional lambda to modify the request
    # @return [Array<Entity>, nil] the concatenated result set or nil if block given
    def get_paged(path, options = {}, request_labda = nil)
      if is_json?
        result = []
        pager = create_pager
        while pager.more_pages?
          response = request(:get, path, options.merge(pager.page_options)) do |req|
            # inject headers...
            request_labda&.call(req)
          end
          handle_data(response.body, pager) do |d|
            if block_given?
              yield(d)
            else
              result = add_data(result, d)
            end
          end
          pager.next_page!(response.body)
        end
        result unless block_given?
      else
        raise ArgumentError, "Pages requests should be json formatted (given format '#{format}')"
      end
    end

    # Perform an HTTP POST request
    #
    # @param path [String] the request path
    # @param options [Hash] the request options
    # @param raw [Boolean] whether to return raw response
    # @return [Entity, String] the response entity or raw response body
    def post(path, options = {}, raw = true)
      response = request(:post, path, options) do |request|
        yield(request) if block_given?
      end
      entity_response(response, raw)
    end

    # Perform an HTTP PUT request
    #
    # @param path [String] the request path
    # @param options [Hash] the request options
    # @param raw [Boolean] whether to return raw response
    # @return [Entity, String] the response entity or raw response body
    def put(path, options = {}, raw = true)
      response = request(:put, path, options) do |request|
        yield(request) if block_given?
      end
      entity_response(response, raw)
    end

    # Perform an HTTP DELETE request
    #
    # @param path [String] the request path
    # @param options [Hash] the request options
    # @param raw [Boolean] whether to return raw response
    # @return [Entity, String] the response entity or raw response body
    def delete(path, options = {}, raw = false)
      response = request(:delete, path, options) do |request|
        yield(request) if block_given?
      end
      entity_response(response, raw)
    end

    # Checks if the response format is JSON
    #
    # @return [Boolean] true if the format is JSON, false otherwise
    def is_json?
      format && 'json'.eql?(format.to_s)
    end

    private

    # Creates a pager for paginated requests
    #
    # @return [Object] the pager instance
    def create_pager
      pagination_class ? pagination_class.new(page_size) : WrAPI::RequestPagination::DefaultPager
    end

    # Perform an HTTP request
    #
    # @param method [Symbol] the HTTP method
    # @param path [String] the request path
    # @param options [Hash] the request options
    # @yieldparam request [Object] the request object
    # @return [Object] the response object
    def request(method, path, options)
      response = connection.send(method) do |request|
        if block_given?
          yield(request)
        end
        request.headers[CONTENT_TYPE_HDR] = "application/#{format}" unless request.headers[CONTENT_TYPE_HDR]

        _path = escape_path(path)
        case method
        when :get, :delete
          request.url(_path.to_s, options)
        when :post, :put
          request.path = _path.to_s
          set_body(request, options)
        end
      end
      response
    end

    # Processes the response and returns an entity if format is JSON
    #
    # @param response [Object] the response object
    # @param raw [Boolean] whether to return raw response
    # @return [Entity, Object] the response entity or raw response
    def entity_response(response, raw = false)
      if is_json? && !raw
        Entity.create(pagination_class.data(response.body))
      else
        response
      end
    end

    # Sets the request body depending on the content type
    #
    # @param request [Object] the request object
    # @param options [Hash] the request options
    def set_body(request, options)
      if is_json? && !options.empty?
        request.body = options.to_json
      else
        request.body = URI.encode_www_form(options) unless options.empty?
      end
    end

    # Handles the data in the response body
    #
    # @param body [String] the response body
    # @param pager [Object] the pager instance
    # @yieldparam data [Object] the data in the response body
    def handle_data(body, pager)
      if d = pager.class.data(body)
        d = Entity.create(d)
        yield(d) if block_given?
      end
    end

    # Adds data to the result array and checks if data itself is an array
    #
    # @param result [Array] the result array
    # @param data [Object] the data to add
    # @return [Array] the updated result array
    def add_data(result, data)
      if data.is_a? Array
        result += data
      else
        result << data
      end
    end

    # Escapes the request path
    #
    # @param path [String] the request path
    # @return [URI::Generic] the escaped path
    def escape_path(path)
      uri = URI::Parser.new
      _path = uri.parse(path)
      _path.path = URI::RFC2396_PARSER.escape(_path.path)
      _path
    end
  end
end
