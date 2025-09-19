#!/usr/bin/env ruby

# Script to configure applications (VSCode and Firefox) for a user
# This script centralizes application configuration logic

require 'optparse'
require 'open3'

class ConfigApps
  def initialize
    @username = ""
    @vscode_port = "8080"
    @display = ":0"
    @vscode_host = "0.0.0.0"
  end

  def show_usage
    puts "Usage: #{$0} [OPTIONS]"
    puts ""
    puts "Required Options:"
    puts "  --username USERNAME    Set the username (required)"
    puts ""
    puts "Optional Options:"
    puts "  --port PORT           Set VS Code port (default: 8080)"
    puts "  --host HOST           Set VS Code host (default: 0.0.0.0)"
    puts "  --display DISPLAY     Set display (default: :0)"
    puts "  --help                Show this help message"
    puts ""
    puts "Examples:"
    puts "  #{$0} --username testuser"
    puts "  #{$0} --username developer --port 9000"
    puts "  #{$0} --username admin  --display :1"
  end

  def parse_arguments
    OptionParser.new do |opts|
      opts.banner = "Usage: #{$0} [OPTIONS]"

      opts.on("--username USERNAME", "Set the username (required)") do |username|
        @username = username
      end

      opts.on("--port PORT", "Set VS Code port") do |port|
        @vscode_port = port
      end

      opts.on("--host HOST", "Set VS Code host") do |host|
        @vscode_host = host
      end

      opts.on("--display DISPLAY", "Set display") do |display|
        @display = display
      end

      opts.on("-h", "--help", "Show this help message") do
        show_usage
        exit 0
      end
    end.parse!

    # Validate required parameters
    if @username.empty?
      puts "Error: Username is required"
      puts ""
      show_usage
      exit 1
    end
  end

  def run_command(command, description = nil)
    puts "Running: #{command}" if description
    stdout, stderr, status = Open3.capture3(command)
    
    unless status.success?
      puts "Error running command: #{command}"
      puts "STDERR: #{stderr}" unless stderr.empty?
      exit 1
    end
    
    stdout
  end

  def user_exists?
    stdout, stderr, status = Open3.capture3("id", @username)
    status.success?
  end

  def main
    parse_arguments
    
    # Check if user exists
    unless user_exists?
      puts "Error: User #{@username} does not exist"
      exit 1
    end

    puts "Configuring applications for user: #{@username}"

    # Configure Firefox
    run_command("/usr/local/bin/add_firefox --username #{@username} --display #{@display}")

    # Configure VS Code
    run_command("/usr/local/bin/add_vscode --username #{@username} --port #{@vscode_port} --host #{@vscode_host} --display #{@display}")
  end
end

# Run the script
ConfigApps.new.main
