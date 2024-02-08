require 'uri'
require 'json'

module WrAPI
  # Defines HTTP request methods
  # required attributes format
  module RequestPagination

    # Defaut pages asumes all sdata retrieved in a single go.
    class DefaultPager

      # initialize with page size
      def initialize(page_size=nil)
        @page = 0
      end

      # go to next page
      # @return true if nore pages
      def next_page!(data=nil)
        @page += 1
        more_pages?
      end

      # assume single page
      def more_pages?
        @page < 1
      end

      def page_options
        {}
      end

      def self.data(body) 
        body
      end
    end

  end
end
