# frozen_string_literal: true

require 'mongo'

module Nanoci
  module DB
    module Mongo
      # Entry point to Mongo DB provider
      class DBMongoProvider
        # Initializes and configured [DBMongoProvider]
        def initialize(ucs)
          hosts = ucs.get(:'db.mongo.clients.default.hosts')
          database = ucs.get(:'db.mongo.clients.default.database')
          options = ucs.get(:'db.mongo.clients.default.options', {})
          options[:database] = database

          ::Mongo::Client.new(hosts, options)
        end
      end
    end
  end
end
