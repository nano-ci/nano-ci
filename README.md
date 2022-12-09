![RSpec](https://github.com/nano-ci/nano-ci/actions/workflows/ruby.yml/badge.svg?branch=main)

# nano-ci v0.1.0

nano-ci is a minimalistic CI/CD system developed with Ruby. The main goal is to
build a CI/CD system for modern large-scale systems consisting of tens and
hundreds software components and dependencies.

## Overview

nano-ci is based on idea of CI/CD pipelines and stages.

A pipeline is directed graph of stages. A single pipeline may have multiple
starting points and multiple output stages. nano-ci does not place any limits.

A stage is a building block of a pipeline. A stage has concept of **inputs** and
**outputs**. **Inputs** and **Outputs** are values consumed or produced by
stages. An output variable of a stage can be connected to input variable of
another stage.

A stage is defined with a list of jobs - sets of commands configured to build
or deploy source code. Jobs are executed in parallel with the same set of input
variables.
A job produces set of output variables. Output variables from all jobs are
merged together in a one set and published as the stage output.

nano-ci uses agents to run jobs. An agent has defined capabilities, i.e. what
tools and utils are configured with the agent. A job is scheduled to execute
on the agent if and only if agent capabilities match the job requirements.

nano-ci kicks off a stage build by trigger (schedule of incomming hook) or when
the stage input variables change.

Connecting stages' outputs with inputs allow developers to define a complete
CI/CD pipeline that takes changes in source code (or NPM packages, gems, Nuget,
etc.), executes build jobs and propagates updates to downstream components.

## Installation

**Alpha**

There are two ways to run nano-ci:
1. Check-out code, install all deps and run *ruby bin/nano-ci* or ...
2. Use docker scripts in *docker*

## Usage

See samples in the directory *samples*.

TODO: Document yaml format of pipeline definition file.

## Development

After checking out the repo, run `bundle setup` to install dependencies. Then, run `rake spec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nano-ci/nano-ci. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The source code is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Nanoci project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/nano-ci/nano-ci/blob/master/CODE_OF_CONDUCT.md).
