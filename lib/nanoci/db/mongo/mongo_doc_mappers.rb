# frozen_string_literal: true

require_relative '../../mapper'

module Nanoci
  module DB
    module Mongo
      # Mongo object mappers
      module MongoDocMappers
        MEMENTO_TO_DOC = Mapper.new do |builder|
          builder.map(:id, to: :_id)
          builder.post_action(&:symbolize_keys)
        end

        DOC_TO_MEMENTO = Mapper.new do |builder|
          builder.map(:_id, to: :id)
          builder.post_action(&:symbolize_keys)
        end
      end
    end
  end
end
