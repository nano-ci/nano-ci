# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: report_job_state_message.proto

require 'google/protobuf'

require 'job_state_pb'
Google::Protobuf::DescriptorPool.generated_pool.build do
  add_message "nanoci.remote.ReportJobStateRequest" do
    optional :project_tag, :string, 1
    optional :job_tag, :string, 2
    optional :agent_tag, :string, 3
    optional :state, :enum, 4, "nanoci.remote.JobState"
  end
  add_message "nanoci.remote.ReportJobStateResponse" do
  end
end

module Nanoci
  module Remote
    ReportJobStateRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("nanoci.remote.ReportJobStateRequest").msgclass
    ReportJobStateResponse = Google::Protobuf::DescriptorPool.generated_pool.lookup("nanoci.remote.ReportJobStateResponse").msgclass
  end
end
