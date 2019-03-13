# frozen_string_literal: true

require 'nanoci/nanoci_class'

module Nanoci
  class Mixins
    ##
    # Module Provides deines a plug-in mechanism
    module Provides
      attr_reader :item_type

      # Registers a provider of a resource
      # @param tag [String] tag to identify the provider
      def provides(tag)
        tag = item_type + ':' + tag unless item_type.nil?
        Nanoci.resources.set(tag, self)
      end

      # Returns the provider of a resource
      # @param tag [String] tag to identify the provider
      # @return [Class] class implementing the resource
      def resolve(tag)
        tag = item_type + ':' + tag unless item_type.nil?
        Nanoci.resources.get(tag)
      end
    end
  end
end
