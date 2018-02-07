require 'mongo'

class Nanoci
  class StateManager
    CREATED_UTC = 'created_utc'.freeze
    TAG = 'tag'.freeze

    def initialize(connection_string)
      @client = Mongo::Client.new(connection_string)
    end

    def put_state(state)
      data = state.clone
      data[CREATED_UTC] = Time.now.strftime('%FT%T.%L%z')
      collection = @client[:state]
      collection.insert_one(data)
    end

    def get_state(tag)
      collection = @client[:state]
      collection.find(tag: tag).sort(CREATED_UTC.to_sym => -1).first
    end
  end
end
