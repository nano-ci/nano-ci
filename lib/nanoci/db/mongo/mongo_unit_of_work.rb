# frozen_string_literal: true

module Nanoci
  module DB
    module Mongo
      # Tracks changes done to domain objects
      class MongoUnitOfWork
        def initialize(client, type_map)
          @client = client
          @type_map = type_map
          @identity_map = {}
          @new_set = Set.new
          @dirty_set = Set.new
          @deleted_set = Set.new
        end
      end
    end
  end
end
