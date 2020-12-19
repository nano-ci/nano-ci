# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/dsl/project_dsl'

RSpec.describe Nanoci::DSL::ProjectDSL do
  it 'builds Hash from DSL' do
    dsl = Nanoci::DSL::ProjectDSL.new(:project_tag, 'project name')
    project_def = dsl.build
    expect(project_def[:tag]).to eq :project_tag
    expect(project_def[:name]).to eq 'project name'
  end

  it 'reads plugin from DSL' do
    dsl = Nanoci::DSL::ProjectDSL.new(:project_tag, 'project name')
    dsl.instance_eval do
      plugin :ruby_plugin, '1.0.0'
    end
    project_def = dsl.build
    expect(project_def[:plugins]).to include(ruby_plugin: '1.0.0')
  end

  it 'reads repo from DSL' do
    dsl = Nanoci::DSL::ProjectDSL.new(:project_tag, 'project name')
    dsl.instance_eval do
      repo :git_repo do
      end
    end
    project_def = dsl.build
    expect(project_def[:repos].length).to eq 1
    expect(project_def[:repos][0][:tag]).to eq :git_repo
  end

  it 'reads pipeline from DSL' do
    dsl = Nanoci::DSL::ProjectDSL.new(:project_tag, 'project name')
    dsl.instance_eval do
      pipeline 'project pipeline' do
      end
    end
    project_def = dsl.build
    expect(project_def[:pipeline]).not_to be nil
  end

  it 'enables operator >> for Symbols' do
    dsl = Nanoci::DSL::ProjectDSL.new(:project_tag, 'project name')
    dsl.instance_eval do
      pipeline 'project pipeline' do
        pipe :abc >> :def
      end
    end
    project_def = dsl.build
    expect(project_def[:pipeline]).to include(pipe: :"abc>>def")
  end
end
