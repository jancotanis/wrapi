require 'uri'
require 'json'
require File.expand_path('entity', __dir__)

module WrAPI
  # Defines HTTP request methods
  # required attributes format
  module Request

    # Perform an HTTP GET request and return entity incase format is :json
    def get(path, options = {})
      response = request(:get, path, options)
      :json.eql?(format) ? Entity.new(response.body) : response.body
    end

    # Perform an HTTP GET request for paged date sets response ind to
    # Name          Description
    # pageSize      The number of records to display per page
    # page          The page number
    # nextPageToken Next page token
    #
    # response format { "page": 0, "totalPages": 0, "total": 0, "nextPageToken": "string", "data": [] }
    def get_paged(path, options = {}, &block)
      raise! ArgumentError,
             "Pages requests should be json formatted (given format '#{format}')" unless :json.eql? format

      result = []
      page = 1
      total = page + 1
      next_page = ''
      while page <= total
        following_page = { pageSize: page_size }
        following_page.merge!({ page: page, nextPageToken: next_page }) unless next_page.empty?

        response = request(:get, path, options.merge(following_page))
        data = response.body
        d = data['data'].map { |e| Entity.new(e) }
        if block_given?
          yield(d)
        else
          result += d
        end
        page += 1
        total = data['totalPages'].to_i
        next_page = data['nextPageToken']
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
