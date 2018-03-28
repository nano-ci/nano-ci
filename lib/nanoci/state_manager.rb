# frozen_string_literal: true

require 'mongo'

class Nanoci
  ##
  # State manager persists or retrieves object state from a storage
  class StateManager
    module Types
      BUILD = :build
      PROJECT = :project
    end

    CREATED_UTC = 'created_utc'
    TAG = 'tag'
    TYPE = 'type'

    def initialize(connection_string)
      @client = Mongo::Client.new(connection_string)
    end

    def put_state(type, state)
      data = state.clone
      data[TYPE] = type
      data[CREATED_UTC] = Time.now
      collection = @client[:state]
      collection.insert_one(data)
    end

    def get_state(type, tag)
      collection = @client[:state]
      collection.find(type: type, tag: tag).sort(CREATED_UTC.to_sym => -1).first
    end
  end
end
