# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/dsl/project_dsl'

RSpec.describe Nanoci::DSL::ProjectDSL do
  it 'builds Hash from DSL' do
    dsl = Nanoci::DSL::ProjectDSL.new(:project_tag, 'project name')
    dsl.instance_eval do
      # rubocop:disable Lint/EmptyBlock
      pipeline :tag, 'name' do
      end
      # rubocop:enable Lint/EmptyBlock
    end
    project = dsl.build
    expect(project.tag).to eq :project_tag
    expect(project.name).to eq 'project name'
  end

  it 'reads plugin from DSL' do
    dsl = Nanoci::DSL::ProjectDSL.new(:project_tag, 'project name')
    dsl.instance_eval do
      plugin :ruby_plugin, '1.0.0'
      # rubocop:disable Lint/EmptyBlock
      pipeline :tag, 'name' do
      end
      # rubocop:enable Lint/EmptyBlock
    end
    project = dsl.build
    expect(project.plugins).to include(ruby_plugin: '1.0.0')
  end

  it 'reads repo from DSL' do
    dsl = Nanoci::DSL::ProjectDSL.new(:project_tag, 'project name')
    dsl.instance_eval do
      # rubocop:disable Lint/EmptyBlock
      pipeline :tag, 'name' do
      end
      # rubocop:enable Lint/EmptyBlock
      repo :git_repo do
        type :git
      end
    end
    project = dsl.build
    expect(project.repos.length).to eq 1
    expect(project.repos[0].tag).to eq :git_repo
  end

  it 'reads pipeline from DSL' do
    dsl = Nanoci::DSL::ProjectDSL.new(:project_tag, 'project name')
    dsl.instance_eval do
      # rubocop:disable Lint/EmptyBlock
      pipeline :pipe, 'project pipeline' do
      end
      # rubocop:enable Lint/EmptyBlock
    end
    project = dsl.build
    expect(project.pipeline).not_to be nil
  end

  it 'enables operator >> for Symbols' do
    dsl = Nanoci::DSL::ProjectDSL.new(:project_tag, 'project name')
    dsl.instance_eval do
      pipeline :pipe, 'project pipeline' do
        # rubocop:disable Lint/EmptyBlock
        stage :abc do
        end
        stage :def do
        end
        # rubocop:enable Lint/EmptyBlock
        pipe :abc >> :def
      end
    end
    project = dsl.build
    expect(project.pipeline.pipes).to include(abc: [:def])
  end
end
