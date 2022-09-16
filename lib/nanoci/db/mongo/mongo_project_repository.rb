# frozen_string_literal: true

require_relative '../../dsl/script_dsl'

module Nanoci
  module DB
    module Mongo
      # Implements ProjectRepositry. Stores data in MongoDB
      class MongoProjectRepository
        PROJECTS_COLLECTION = :projects

        def initialize(client)
          @client = client
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

        def find_one(query)
          docs = []
          @client[PROJECTS_COLLECTION].find(query).each do |d|
            docs.push(d)
          end

          raise 'multiple result docs in output' if docs.count > 1

          docs.first
        end

        def insert_project(memento)
          doc = map_memento_to_doc(memento)
          result = @client[PROJECTS_COLLECTION].insert_one(doc)
          memento[:id] = result.inserted_id if result.successful?
          memento
        end

        def update_project(memento, doc)
          doc = map_memento_to_doc(memento, doc)
          @client[PROJECTS_COLLECTION].find_one_and_update({ _id: doc[:_id] }, doc)
        end

        def map_memento_to_doc(memento)
          doc = {}
          doc[:_id] = memento[:id] if memento.key? :id
          doc[:tag] = memento[:tag]
          doc[:src] = memento[:src]
          doc
        end

        def map_doc_to_memento(doc)
          memento = {}
          memento[:id] = doc[:_id]
          memento[:tag] = doc[:tag]
          memento[:src] = doc[:src]
          memento
        end
      end
    end
  end
end
