# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: agent_status.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_enum "nanoci.remote.AgentStatus" do
    value :UNKNOWN, 0
    value :IDLE, 1
    value :PENDING, 2
    value :BUSY, 3
  end
end

module Nanoci
  module Remote
    AgentStatus = Google::Protobuf::DescriptorPool.generated_pool.lookup("nanoci.remote.AgentStatus").enummodule
  end
end
