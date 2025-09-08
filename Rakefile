# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "cucumber/rake/task"
require "rubocop/rake_task"
require "yard"

RSpec::Core::RakeTask.new(:spec)

Cucumber::Rake::Task.new(:cucumber) do |task|
  task.cucumber_opts = "--format pretty"
end

RuboCop::RakeTask.new

YARD::Rake::YardocTask.new do |task|
  task.files = ["lib/**/*.rb"]
  task.options = ["--markup", "markdown"]
end

desc "Run all tests"
task test: [:spec, :cucumber]

desc "Run all quality checks"
task quality: [:rubocop, :yard]

desc "Run all checks (tests and quality)"
task check: [:test, :quality]

task default: :check

