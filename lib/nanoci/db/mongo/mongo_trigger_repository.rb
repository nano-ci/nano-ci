# frozen_string_literal: true

require_relative '../../trigger_repository'

module Nanoci
  module DB
    module Mongo
      class MongoTriggerRepository < TriggerRepository
        TRIGGERS_COLLECTION = :triggers

        def initialize(client)
          super()
          @client = client
        end

        def due_triggers?(now_timestamp)
          query = {
            next_run_time: {
              '$lte': now_timestamp
            },
            FIELD_LOCK => LOCK_WAITING
          }
          @client[TRIGGERS_COLLECTION].find(query).count.positive?
        end

        protected

        def find_by_tag(tag)
          docs = []
          @client[TRIGGERS_COLLECTION].find(tag: tag).each do |d|
            docs.push(d)
          end

          raise 'multiple result docs in output' if docs.count > 1

          docs.first
        end

        def find_and_lock_due_doc(now_timestamp, state)
          query = {
            next_run_time: {
              '$lte': now_timestamp
            },
            FIELD_LOCK => state
          }
          update = {
            '$set': {
              FIELD_LOCK => LOCK_EXECUTING,
              FIELD_LOCK_EXPIRES => Time.now.utc + LOCK_TIMEOUT
            }
          }
          @client[TRIGGERS_COLLECTION].find_one_and_update(query, update, return_document: :after)
        end

        def update_and_release_doc(id, doc)
          query = { _id: id, FIELD_LOCK => LOCK_EXECUTING }
          update = {
            '$set': doc.merge({
                                FIELD_LOCK => LOCK_WAITING,
                                FIELD_LOCK_EXPIRES => nil
                              })
          }
          @client[TRIGGERS_COLLECTION].find_one_and_update(query, update, return_document: :after)
        end

        def insert_doc(doc)
          result = @client[TRIGGERS_COLLECTION].insert_one(doc)
          doc[:_id] = result.inserted_id if result.successful?
          doc
        end
      end
    end
  end
end
