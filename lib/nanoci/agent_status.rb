# frozen_string_literal: true

require 'ruby-enum'

module Nanoci
  # Enumeration of valid agent status
  class AgentStatus
    include Ruby::Enum

    define :UNKNOWN, 0
    define :IDLE, 1
    define :PENDING, 2
    define :BUSY, 3
  end
end
