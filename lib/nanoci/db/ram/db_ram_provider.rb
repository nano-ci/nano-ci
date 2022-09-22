# frozen_string_literal: true

require_relative '../../project_repository'
require_relative '../../trigger_repository'

module Nanoci
  module DB
    module Ram
      # Entry point to Ram DB provider
      class DBRamProvider
        attr_reader :project_repository, :trigger_repository

        def initialize
          @project_repository = Nanoci::ProjectRepository.new
          @trigger_repository = Nanoci::TriggerRepository.new
        end
      end
    end
  end
end
