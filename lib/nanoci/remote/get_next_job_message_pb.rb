# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: get_next_job_message.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_message "nanoci.remote.GetNextJobRequest" do
    optional :tag, :string, 1
  end
  add_message "nanoci.remote.GetNextJobResponse" do
    optional :has_job, :bool, 1
    optional :build_tag, :string, 2
    optional :project_tag, :string, 3
    optional :stage_tag, :string, 4
    optional :job_tag, :string, 5
    optional :project_definition, :string, 6
    map :variables, :string, :string, 7
    map :commits, :string, :string, 8
  end
end

module Nanoci
  module Remote
    GetNextJobRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("nanoci.remote.GetNextJobRequest").msgclass
    GetNextJobResponse = Google::Protobuf::DescriptorPool.generated_pool.lookup("nanoci.remote.GetNextJobResponse").msgclass
  end
end