# frozen_string_literal: true

module Nanoci
  ##
  # An artifact is the output of job and may contains files or folders
  class Artifact
    attr_accessor :tag
    attr_accessor :path
    attr_accessor :pattern

    def initialize(hash = {})
      @tag = hash['tag']
      @path = hash['path']
      @pattern = Regexp.new(hash['pattern']) unless hash['pattern'].nil?
    end
  end
end
