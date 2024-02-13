require 'uri'
require 'json'

module WrAPI
  # Defines HTTP request methods
  # required attributes format
  module Request

    # Perform an HTTP GET request and return entity incase format is :json
    #  @return if format is :json an [Entity] is returned, otherwhise the response body
    def get(path, options = {})
      response = request(:get, path, options) do |request|
        yield(request) if block_given?
      end
      :json.eql?(format) ? Entity.new(pagination_class.data(response.body)) : response.body
    end

    # Perform an HTTP GET request for paged date sets response
    #  @return nil if block given, otherwise complete concatenated json result set
    def get_paged(path, options = {}, request_labda = nil)
      raise ArgumentError,
            "Pages requests should be json formatted (given format '#{format}')" unless :json.eql? format

      result = []
      pager = create_pager
      while pager.more_pages?
        response = request(:get, path, options.merge(pager.page_options)) do |req|
          request_labda.call(req) if request_labda
        end
        d = pager.class.data(response.body)
        if d.is_a? Array
          d = pager.class.data(response.body).map { |e| Entity.new(e) }
        else
          d = Entity.new(d)
        end
        if block_given?
          yield(d)
        else
          if d.is_a? Array
            result += d
          else
            result << d
          end
        end
        pager.next_page!(response.body)
      end
      result unless block_given?
    end

    # Perform an HTTP POST request
    # @return response is returned in json if format is :json
    def post(path, options = {})
      response = request(:post, path, options) do |request|
        yield(request) if block_given?
      end
    end

    # Perform an HTTP PUT request
    # @return response is returned in json if format is :json
    def put(path, options = {})
      response = request(:put, path, options) do |request|
        yield(request) if block_given?
      end
    end

    # Perform an HTTP DELETE request
    # @return response is returened
    def delete(path, options = {})
      response = request(:delete, path, options) do |request|
        yield(request) if block_given?
      end
    end

    private

    def create_pager
      pagination_class ? pagination_class.new(page_size) : WrAPI::RequestPagination::DefaultPager
    end

    # Perform an HTTP request
    def request(method, path, options)
      response = connection.send(method) do |request|
        yield(request) if block_given?
        uri = URI::Parser.new
        case method
        when :get, :delete
          request.url(uri.escape(path), options)
        when :post, :put
          request.headers['Content-Type'] = "application/#{format}"
          request.path = uri.escape(path)
          request.body = options.to_json unless options.empty?
        end
      end
      response
    end
  end
end
