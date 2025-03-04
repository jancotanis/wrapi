# frozen_string_literal: true

require 'uri'
require 'json'

module WrAPI
  # Defines HTTP request methods and required attributes format for pagination.
  module RequestPagination
    # DefaultPager handles pagination by assuming all data is retrieved in a single go.
    class DefaultPager
      # Initializes the pager with an optional page size.
      #
      # @param _page_size [Integer, nil] the size of the page (not used in this implementation)
      def initialize(_page_size = nil)
        @page = 0
      end

      # Advances to the next page.
      #
      # @param _data [Object, nil] the data from the current page (not used in this implementation)
      # @return [Boolean] true if there are more pages, false otherwise
      def next_page!(_data = nil)
        @page += 1
        more_pages?
      end

      # Checks if there are more pages.
      #
      # @return [Boolean] true if there are more pages, false otherwise
      def more_pages?
        @page < 1
      end

      # Returns options for the current page to add to get request.
      #
      # @return [Hash] an empty hash as options
      def page_options
        {}
      end

      # Processes the data from the response body.
      #
      # @param body [Object] the response body
      # @return [Object] the processed data (in this case, the body itself)
      def self.data(body)
        body
      end
    end
  end
end
