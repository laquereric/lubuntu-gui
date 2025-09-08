# frozen_string_literal: true

require "bundler/setup"
require "lubuntu_gui"
require "simplecov"

# Start SimpleCov for code coverage
SimpleCov.start do
  add_filter "/spec/"
  add_filter "/features/"
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on Module and main
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Mock external commands during testing
  config.before(:each) do
    allow(LubuntuGui::CommandExecutor).to receive(:execute).and_return({
      stdout: "",
      stderr: "",
      success: true,
      exit_code: 0
    })
    
    allow(LubuntuGui::CommandExecutor).to receive(:safe_execute).and_return({
      stdout: "",
      stderr: "",
      success: true,
      exit_code: 0
    })
    
    allow(LubuntuGui::CommandExecutor).to receive(:command_exists?).and_return(true)
  end
end

