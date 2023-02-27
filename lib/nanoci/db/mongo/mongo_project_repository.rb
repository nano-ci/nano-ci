# frozen_string_literal: true

require 'time'

require_relative '../../dsl/script_dsl'

module Nanoci
  module DB
    module Mongo
      # Implements ProjectRepositry. Stores data in MongoDB
      class MongoProjectRepository
        def initialize(client, klass, type_map)
          @client = client
          @klass = klass
          @collection_name = type_map[:collection]
          @to_doc_mapper = type_map[:to_doc_mapper]
          @from_doc_mapper = type_map[:from_doc_mapper]
        end

        # Adds a project to the repository
        # @param project [Nanoci::Core::Project]
        # @return [Nanoci::Core::Project]
        def add(project)
          # find project by tag
          # if exists - restore memento
          # if not - store memento + update #id

          doc = find_one(tag: project.tag)

          project.memento = @from_doc_mapper.map(doc.nil? ? insert_project(project.memento) : doc.symbolize_keys, {})

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

          memento = @from_doc_mapper.map(doc.symbolize_keys, {})
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
          doc = @to_doc_mapper.map(memento, {})
          result = collection.insert_one(doc)
          doc[:_id] = result.inserted_id if result.successful?
          doc
        end

        def update_project(memento)
          doc = @to_doc_mapper.map(memento, {})
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
      end
    end
  end
end
