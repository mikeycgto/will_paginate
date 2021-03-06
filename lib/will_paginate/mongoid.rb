require 'mongoid'
require 'will_paginate/collection'

module WillPaginate
  module Mongoid
    module CriteriaMethods
      def paginate(options = {})
        extend CollectionMethods
        @current_page = WillPaginate::PageNumber(options[:page] || @current_page || 1)
        @page_multiplier = current_page - 1
        model_pp = klass.respond_to?(:per_page) ? klass.per_page : nil
        pp = (options[:per_page] || per_page || model_pp || WillPaginate.per_page).to_i
        limit(pp).skip(@page_multiplier * pp)
      end

      def per_page(value = :non_given)
        value == :non_given ? options[:limit] : limit(value)
      end

      def page(page)
        paginate(:page => page)
      end
    end

    module CollectionMethods
      attr_reader :current_page

      def total_entries
        @total_entries ||= count
      end

      def total_pages
        (total_entries / per_page.to_f).ceil
      end

      def offset
        @page_multiplier * per_page
      end
    end

    ::Mongoid::Criteria.send(:include, CriteriaMethods)
  end
end
