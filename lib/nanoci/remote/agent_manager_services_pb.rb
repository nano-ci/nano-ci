# Generated by the protocol buffer compiler.  DO NOT EDIT!
# Source: agent_manager.proto for package 'nanoci.remote'

require 'grpc'
require 'agent_manager_pb'

module Nanoci
  module Remote
    module AgentManager
      class Service

        include GRPC::GenericService

        self.marshal_class_method = :encode
        self.unmarshal_class_method = :decode
        self.service_name = 'nanoci.remote.AgentManager'

        rpc :GetNextJob, GetNextJobRequest, GetNextJobResponse
        rpc :ReportAgentStatus, ReportAgentStatusRequest, ReportAgentStatusResponse
      end

      Stub = Service.rpc_stub_class
    end
  end
end
