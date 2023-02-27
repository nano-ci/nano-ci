# frozen_string_literal: true

require 'hashdiff'

require_relative '../entity_tracker'

module Nanoci
  module DB
    module Mongo
      # Tracks changes done to domain objects
      class MongoUnitOfWork
        def initialize(client, type_map)
          @client = client
          @type_map = type_map
          # @type [Hash]
          @identity_map = {}
          # @type [Set]
          @new_set = Set.new
          # @type [Set]
          @deleted_set = Set.new
        end

        def find(id)
          @identity_map[id]&.entity
        end

        def register_new(entity)
          raise ArgumentError, '#id is not nil, the entity is not new' unless entity.id.nil?

          identity = EntityTracker.new(entity)
          @new_set.add(identity)
          nil
        end

        def register(entity)
          raise ArgumentError, '#id is nil, the entity is new' if entity.id.nil?

          identity = EntityTracker.new(entity)
          @deleted_set.delete? identity
          @identity_map[identity.id] = identity
          nil
        end

        def register_deleted(entity)
          raise ArgumentError, '#id is nil, the entity is new' if entity.id.nil?

          identity = EntityTracker.new(entity)
          @identity_map.delete(identity.id)
          @deleted_set.add(identity)
          nil
        end

        def commit
          persist_updates
          persist_deleted
          persist_new
        end

        private

        def persist_updates
          identity_map.each do |id, t|
            memento = t.entity.memento
            next if t.memento == memento

            actions = build_update_actions(Hashdiff(t.memento, memento))

            filter = { _id: id }
            collection(t.entity).update_one(filter, actions)
          end
          identity_map.each_value(&:reset)
        end

        # rubocop:disable Metrics:AbcSize
        def build_update_actions(diff)
          actions = {}
          gr = diff.group_by { |d| d[0] }
          add = gr.fetch('+', []).map { |a| [a[1], a[2]] }
          replace = gr.fetch('~', []).map { |a| [a[1], a[3]] }
          actions['$unset'] = gr['-'].to_h { |a| [a[1], ''] } if gr.key('-')
          actions['$set'] = (add + replace).to_h if add.any? || replace.any?
          actions
        end
        # rubocop:enable Metrics:AbcSize

        # rubocop:disable Metrics:MethodLength
        def persist_new
          inserted = []
          @new_set.each do |tracker|
            entity = tracker.entity
            doc = entity_to_doc(entity)
            result = collection(entity).insert_one(doc)
            next unless result.successful?

            doc[:_id] = result.inserted_id
            entity.memento = from_doc_mapper(entity).map(doc, {})
            inserted.push(tracker)
          end

          store_inserted_identities(inserted)
        end
        # rubocop:enable Metrics:MethodLength

        def persist_deleted
          trackers_by_class = @deleted_set.group_by { |x| x.entity.class }
          trackers_by_class.each do |klass, trackers|
            ids = trackers.map(&:id)
            collection = @client[@type_map.fetch(klass)[:collection]]
            collection.delete_many(_id: { '$in': ids })
            @deleted_set.subtract(trackers)
          end
        end

        def store_inserted_identities(inserted)
          inserted.each do |t|
            t.reset
            @new_set.delete(t)

            @identity_map[identity.id] = identity
          end
        end

        def collection(entity)
          @client[@type_map.fetch(entity.class)][:collection]
        end

        def entity_to_doc(entity)
          @type_map.fetch(entity.class)[:to_doc_mapper].map(tracker.entity.memento, {})
        end

        def from_doc_mapper(entity)
          @type_map.fetch(entity.class)[:from_doc_mapper]
        end
      end
    end
  end
end
