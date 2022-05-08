# frozen_string_literal: true

require 'nanoci/not_implemented_error'

module Nanoci
  module Core
    class StageCompleteObserver
      def pulse(tag, outputs)
        raise NotImplementedError
      end
    end
  end
end
