require 'uri'
require 'json'

module WrAPI
  # Defines HTTP request methods
  # required attributes format
  module Request

    # Perform an HTTP GET request and return entity incase format is :json
    def get(path, options = {})
      response = request(:get, path, options)
      :json.eql?(format) ? Entity.new(pagination_class.data(response.body)) : response.body
    end

    # Perform an HTTP GET request for paged date sets response
    def get_paged(path, options = {}, &block)
      raise ArgumentError,
            "Pages requests should be json formatted (given format '#{format}')" unless :json.eql? format

      result = []
      pager = create_pager
      while pager.more_pages?
        response = request(:get, path, options.merge(pager.page_options))
        #data = response.body
        d = pager.class.data(response.body).map { |e| Entity.new(e) }
        if block_given?
          yield(d)
        else
          result += d
        end
        pager.next_page!(response.body)
      end
      result unless block_given?
    end

    # Perform an HTTP POST request
    def post(path, options = {})
      request(:post, path, options)
    end

    # Perform an HTTP PUT request
    def put(path, options = {})
      request(:put, path, options)
    end

    # Perform an HTTP DELETE request
    def delete(path, options = {})
      request(:delete, path, options)
    end

    private

    def create_pager
      pagination_class.new(page_size)
    end

    # Perform an HTTP request
    def request(method, path, options)
      response = connection.send(method) do |request|
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
