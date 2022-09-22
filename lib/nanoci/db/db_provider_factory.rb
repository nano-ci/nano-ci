# frozen_string_literal: true

require_relative '../config/ucs'
require_relative 'mongo/db_mongo_provider'
require_relative 'ram/db_ram_provider'

module Nanoci
  module DB
    # Provides a method to get current DB storage provider
    class DBProviderFactory
      def initialize
        @provider_classes = {
          mongo: Nanoci::DB::Mongo::DBMongoProvider,
          ram: Nanoci::DB::Ram::DBRamProvider
        }

        @current = nil
      end

      def current_provider
        if @current.nil?
          ucs = Nanoci::Config::UCS.instance

          provider_key = ucs.get(:'db.provider').to_sym

          raise ArgumentError, "db provider #{provider_key} is not supported" unless @provider_classes.key? provider_key

          clazz = @provider_classes[provider_key]
          @current = clazz.new
        end
        @current
      end
    end
  end
end
