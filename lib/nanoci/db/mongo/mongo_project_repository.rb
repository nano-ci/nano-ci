# frozen_string_literal: true

require 'time'

require_relative '../../dsl/script_dsl'

module Nanoci
  module DB
    module Mongo
      # Implements ProjectRepositry. Stores data in MongoDB
      class MongoProjectRepository
        def initialize(client, klass, collection_name)
          @client = client
          @klass = klass
          @collection_name = collection_name
        end

        # Adds a project to the repository
        # @param project [Nanoci::Core::Project]
        # @return [Nanoci::Core::Project]
        def add(project)
          # find project by tag
          # if exists - restore memento
          # if not - store memento + update #id

          doc = find_one(tag: project.tag)

          project.memento = doc.nil? ? insert_project(project.memento) : map_doc_to_memento(doc.symbolize_keys)

          project
        end

        def save(project)
          update_project(project.memento)
        end

        def save_stage(project, stage)
          update_stage(project.id, stage.tag, stage.memento)
        end

        def find_by_tag(tag)
          doc = find_one(tag: tag)

          return nil if doc.nil?

          memento = map_doc_to_memento(doc)
          script_dsl = DSL::ScriptDSL.from_string(memento[:src])
          project_dsl = script_dsl.projects[0]
          project = project_dsl.build
          project.memento = memento
          project
        end

        private

        def collection
          @client[@collection_name]
        end

        def find_one(query)
          docs = []
          collection.find(query).each do |d|
            docs.push(d)
          end

          raise 'multiple result docs in output' if docs.count > 1

          docs.first
        end

        def insert_project(memento)
          doc = map_memento_to_doc(memento)
          result = collection.insert_one(doc)
          memento[:id] = result.inserted_id if result.successful?
          memento
        end

        def update_project(memento)
          doc = map_memento_to_doc(memento)
          collection.find_one_and_update({ _id: doc[:_id] }, doc)
        end

        def update_stage(project_id, stage_tag, memento)
          update_doc = {
            '$set': {
              "pipeline.stages.#{stage_tag}": memento
            },
            '$currentDate': { last_modified_ts: true }
          }
          collection.find_one_and_update({ _id: project_id }, update_doc)
        end

        def map_memento_to_doc(memento)
          doc = {}
          doc[:_id] = memento[:id] if memento.key? :id
          doc[:tag] = memento[:tag]
          doc[:src] = memento[:src]
          doc[:pipeline] = memento[:pipeline] if memento.key? :pipeline
          doc
        end

        def map_doc_to_memento(doc)
          memento = {}
          memento[:id] = doc[:_id]
          memento[:tag] = doc[:tag]
          memento[:src] = doc[:src]
          memento[:pipeline] = doc[:pipeline] if doc.key? :pipeline
          memento.symbolize_keys
        end
      end
    end
  end
end
