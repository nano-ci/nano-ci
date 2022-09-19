# frozen_string_literal: true

require 'mongo'

require_relative './mongo_project_repository'
require_relative '../../config/ucs'

module Nanoci
  module DB
    module Mongo
      # Entry point to Mongo DB provider
      class DBMongoProvider
        def project_repository
          @project_repository ||= MongoProjectRepository.new(client)
        end

        private

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
