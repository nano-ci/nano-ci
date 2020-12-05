# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/dsl/project_dsl'

RSpec.describe Nanoci::DSL::ProjectDSL do
  it 'builds ProjectDefinition from DSL' do
    dsl = Nanoci::DSL::ProjectDSL.new(:project_tag, 'project name')
    project_def = dsl.build
    expect(project_def.tag).to eq :project_tag
    expect(project_def.name).to eq 'project name'
  end

  it 'reads plugin from DSL' do
    dsl = Nanoci::DSL::ProjectDSL.new(:project_tag, 'project name')
    dsl.instance_eval do
      plugin :ruby_plugin, '1.0.0'
    end
    project_def = dsl.build
    expect(project_def.plugins).to include(ruby_plugin: '1.0.0')
  end
end
