# frozen_string_literal: true

require_relative '../../trigger_repository'

module Nanoci
  module DB
    module Mongo
      # Implements TriggerRepository. Stores data in MongoDB
      class MongoTriggerRepository < TriggerRepository
        def initialize(client, klass, type_map)
          super()
          @client = client
          @class = klass
          @collecion_name = type_map[:collection]
          @from_doc_mapper = type_map[:from_doc_mapper]
          @to_doc_mapper = type_map[:to_doc_mapper]
        end

        def due_triggers?(due_ts:, projects:)
          query = build_due_triggers_query(due_ts: due_ts, projects: projects, state: LOCK_WAITING)
          collection.find(query).count.positive?
        end

        protected

        def collection
          @client[@collecion_name]
        end

        def find_by_tag(project_tag, tag)
          docs = []
          collection.find(project_tag: project_tag, tag: tag).each do |d|
            docs.push(d)
          end

          raise 'multiple result docs in output' if docs.count > 1

          docs.first
        end

        def find_and_lock_due_doc(due_ts:, projects:, state:)
          query = build_due_triggers_query(due_ts: due_ts, projects: projects, state: state)
          update = {
            '$set': {
              FIELD_LOCK => LOCK_EXECUTING,
              FIELD_LOCK_EXPIRES => Time.now.utc + LOCK_TIMEOUT
            }
          }
          collection.find_one_and_update(query, update, return_document: :after)
        end

        def update_and_release_doc(id, doc)
          query = { _id: id, FIELD_LOCK => LOCK_EXECUTING }
          update = {
            '$set': doc.merge({
                                FIELD_LOCK => LOCK_WAITING,
                                FIELD_LOCK_EXPIRES => nil
                              })
          }
          collection.find_one_and_update(query, update, return_document: :after)
        end

        def insert_doc(doc)
          result = collection.insert_one(doc)
          doc[:_id] = result.inserted_id if result.successful?
          doc
        end

        def build_due_triggers_query(due_ts:, projects:, state:)
          {
            next_run_time: {
              '$lte': due_ts
            },
            project_tag: {
              '$in': projects
            },
            FIELD_LOCK => state
          }
        end
      end
    end
  end
end
