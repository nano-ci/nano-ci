# frozen_string_literal: true

module Nanoci
  module DB
    # Data model for UoW to track entities
    class EntityTracker
      attr_reader :id, :memento, :entity

      def initialize(entity)
        @entity = entity
        reset
      end

      def reset
        @id = entity.id
        @memento = entity.memento
      end

      def eql?(other)
        !other.nil? && other.is_a?(EntityTracker) && id == other.id && entity == other.entity
      end

      def hash
        [self.class, id, entity].hash
      end
    end
  end
end
