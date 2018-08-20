# frozen_string_literal: true

require 'nanoci/nanoci_class'

class Nanoci
  class Mixins
    ##
    # Module Provides deines a plug-in mechanism
    module Provides
      # Registers a provider of a resource
      # @param tag [String] tag to identify the provider
      def provides(tag)
        Nanoci.resources.set(tag, self)
      end

      # Returns the provider of a resource
      # @param tag [String] tag to identify the provider
      # @return [Class] class implementing the resource
      def resolve(tag)
        Nanoci.resources.get(tag)
      end
    end
  end
end
