require 'uri'
require 'json'

module WrAPI
  # Defines HTTP request methods
  # required attributes format
  module Request
    CONTENT_TYPE_HDR = 'Content-Type'.freeze
    # Perform an HTTP GET request and return entity incase format is :json
    #  @return if format is :json and !raw an [Entity] is returned, otherwhise the response body
    def get(path, options = {}, raw=false)
      response = request(:get, path, options) do |request|
        # inject headers...
        yield(request) if block_given?
      end
      entity_response(response, raw)
    end

    # Perform an HTTP GET request for paged date sets response
    #  @return nil if block given, otherwise complete concatenated json result set
    def get_paged(path, options = {}, request_labda = nil)
      raise ArgumentError,
            "Pages requests should be json formatted (given format '#{format}')" unless is_json?

      result = []
      pager = create_pager
      while pager.more_pages?
        response = request(:get, path, options.merge(pager.page_options)) do |req|
          # inject headers...
          request_labda.call(req) if request_labda
        end
        handle_data(response.body,pager) do |d|
          if block_given?
            yield(d)
          else
            result = add_data(result,d)
          end
        end
        pager.next_page!(response.body)
      end
      result unless block_given?
    end

    # Perform an HTTP POST request
    # @return response is returned in json if format is :json
    def post(path, options = {}, raw=true)
      response = request(:post, path, options) do |request|
        yield(request) if block_given?
      end
      entity_response(response, raw)
    end

    # Perform an HTTP PUT request
    # @return response is returned in json if format is :json
    def put(path, options = {}, raw=true)
      response = request(:put, path, options) do |request|
        yield(request) if block_given?
      end
      entity_response(response, raw)
    end

    # Perform an HTTP DELETE request
    # @return response is returened
    def delete(path, options = {}, raw=false)
      response = request(:delete, path, options) do |request|
        yield(request) if block_given?
      end
      entity_response(response, raw)
    end

    def is_json?
      format && 'json'.eql?(format.to_s)
    end

  private

    def create_pager
      pagination_class ? pagination_class.new(page_size) : WrAPI::RequestPagination::DefaultPager
    end

    # Perform an HTTP request
    def request(method, path, options)
      response = connection.send(method) do |request|
        yield(request) if block_given?
        request.headers[CONTENT_TYPE_HDR] = "application/#{format}" unless request.headers[CONTENT_TYPE_HDR]
        uri = URI::Parser.new
        _path = uri.parse(path)
        _path.path = uri.escape(_path.path)
        case method
        when :get, :delete
          request.url(_path.to_s, options)
        when :post, :put
          request.path = _path.to_s
          set_body(request,options)
        end
      end
      response
    end

    def entity_response(response, raw=false)
      if is_json? && !raw
        Entity.create(pagination_class.data(response.body))
      else
        response
      end
    end

    # set post body depending json content-type
    def set_body(request,options)
      if is_json? && !options.empty?
        request.body = options.to_json
      else
        request.body = URI.encode_www_form(options) unless options.empty?
      end
    end
    def handle_data(body,pager)
      if d = pager.class.data(body)
        d = Entity.create(d)
        yield(d) if block_given?
      end
    end
    # add data to array and check if data itself is an array
    def add_data(result,data)
      if data.is_a? Array
        result += data
      else
        result << data
      end
    end
  end
end
