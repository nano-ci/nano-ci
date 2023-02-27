# frozen_string_literal: true

require 'mongo'

require_relative '../../config/ucs'
require_relative 'mongo_project_repository'
require_relative 'mongo_trigger_repository'
require_relative 'mongo_unit_of_work'

module Nanoci
  module DB
    module Mongo
      # Entry point to Mongo DB provider
      class DBMongoProvider
        # Creates and returns a new unit of work
        def unit_of_work
          MongoUnitOfWork.new(client, TYPE_MAP)
        end

        def project_repository
          klass = Nanoci::Core::Project
          @project_repository ||= MongoProjectRepository.new(client, klass, TYPE_MAP.fetch(klass))
        end

        def trigger_repository
          klass = Nanoci::Core::Trigger
          @trigger_repository ||= MongoTriggerRepository.new(client, klass, TYPE_MAP.fetch(klass))
        end

        private

        TYPE_MAP = {
          Nanoci::Core::Project => {
            collection: :projects,
            to_doc_mapper: MongoDocMappers::MEMENTO_TO_DOC,
            from_doc_mapper: MongoDocMappers::DOC_TO_MEMENTO
          },
          Nanoci::Core::Trigger => {
            collection: :triggers,
            to_doc_mapper: MongoDocMappers::MEMENTO_TO_DOC,
            from_doc_mapper: MongoDocMappers::DOC_TO_MEMENTO
          }
        }.freeze

        CLIENT_OPTIONS = %i[app_name].freeze

        def client
          @client ||= create_client
        end

        def create_client
          ucs = Nanoci::Config::UCS.instance
          hosts = ucs.get(:'db.mongo.clients.default.hosts')
          options = { database: ucs.get(:'db.mongo.clients.default.database') }

          CLIENT_OPTIONS.each do |o|
            k = "db.mongo.clients.default.options.#{o}".to_sym
            options[o] = ucs.get(k) if ucs.key? k
          end

          ::Mongo::Client.new(hosts, options)
        end
      end
    end
  end
end
