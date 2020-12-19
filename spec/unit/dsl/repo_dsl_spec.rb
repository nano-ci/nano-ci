# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/dsl/repo_dsl'

RSpec.describe Nanoci::DSL::RepoDSL do
  it 'reads type from DSL' do
    dsl = Nanoci::DSL::RepoDSL.new(:git_repo)
    dsl.instance_eval do
      type :git
    end
    expect(dsl.build[:type]).to eq :git
  end

  it 'reads uri from DSL' do
    dsl = Nanoci::DSL::RepoDSL.new(:git_repo)
    dsl.instance_eval do
      uri 'https://github.com'
    end
    expect(dsl.build[:uri]).to eq 'https://github.com'
  end

  it 'reads auth from DSL' do
    dsl = Nanoci::DSL::RepoDSL.new(:git_repo)
    dsl.instance_eval do
      auth(key: '/abc/def', password: 'abcde')
    end
    expect(dsl.build[:auth]).to include(key: '/abc/def')
    expect(dsl.build[:auth]).to include(password: 'abcde')
  end
end
