# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/dsl/project_dsl'

RSpec.describe Nanoci::DSL::ProjectDSL do
  it 'builds ProjectDefinition from DSL' do
    dsl = Nanoci::DSL::ProjectDSL.new
    dsl.tag = :project_tag
    dsl.name = 'project name'
    project_def = dsl.build
    expect(project_def.tag).to eq :project_tag
    expect(project_def.name).to eq 'project name'
  end
end
