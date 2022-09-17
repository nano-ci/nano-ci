# frozen_string_literal: true

module Nanoci
  module Config
    # UCS config module to access nano-ci system variables
    module SystemConfig
      # @return path to plugins directory
      def plugins_path
        get(SystemConfig::PLUGINS_PATH)
      end

      # plugins-path config name
      PLUGINS_PATH = :'plugins-path'
    end
  end
end
