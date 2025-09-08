# frozen_string_literal: true

require "bundler/setup"
require "lubuntu_gui"

# Mock external commands during testing
Before do
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

