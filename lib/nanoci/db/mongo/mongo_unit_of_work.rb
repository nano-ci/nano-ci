# frozen_string_literal: true

require 'hashdiff'

require_relative '../entity_tracker'

module Nanoci
  module DB
    module Mongo
      # Tracks changes done to domain objects
      class MongoUnitOfWork
        def initialize(client, type_map)
          # @type [Mongo::Client]
          @client = client
          @session = @client.start_session
          @type_map = type_map
          # @type [Hash]
          @identity_map = {}
          # @type [Set]
          @new_set = Set.new
          # @type [Set]
          @deleted_set = Set.new
        end

        def closed? = @session.ended?

        def find(id)
          @identity_map[id]&.entity
        end

        def register_new(entity)
          raise 'unit of work is closed' if closed?
          raise ArgumentError, '#id is not nil, the entity is not new' unless entity.id.nil?

          @new_set.add(EntityTracker.new(entity))
          nil
        end

        def register(entity)
          raise 'unit of work is closed' if closed?
          raise ArgumentError, '#id is nil, the entity is new' if entity.id.nil?

          identity = EntityTracker.new(entity)
          @deleted_set.delete? identity
          @identity_map[identity.id] = identity
          nil
        end

        def register_deleted(entity)
          raise 'unit of work is closed' if closed?
          raise ArgumentError, '#id is nil, the entity is new' if entity.id.nil?

          identity = EntityTracker.new(entity)
          @identity_map.delete(identity.id)
          @deleted_set.add(identity)
          nil
        end

        def commit
          raise 'unit of work is closed' if closed?

          @session.start_transaction
          persist_updates
          persist_deleted
          persist_new
          @session.commit_transaction
          @session.end_session
        end

        private

        def persist_updates
          identity_map.each do |id, t|
            next if t.memento == t.entity.memento

            actions = build_update_actions(Hashdiff(t.memento, t.entity.memento))

            filter = { _id: id }
            collection(t.entity).update_one(filter, actions, session: @session)
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
            result = collection(entity).insert_one(doc, session: @session)
            next unless result.successful?

            doc[:_id] = result.inserted_id
            doc_to_entity(entity, doc)
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
            collection.delete_many(_id: { '$in': ids }, session: @session)
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
          @type_map.fetch(entity.class)[:to_doc_mapper].map(entity.memento, {})
        end

        def doc_to_entity(doc, entity)
          entity.memento = @type_map.fetch(entity.class)[:from_doc_mapper].map(doc)
        end
      end
    end
  end
end
