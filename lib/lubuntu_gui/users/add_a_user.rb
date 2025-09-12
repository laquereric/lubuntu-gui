#!/usr/bin/env ruby

# Script to add a user with optional VS Code auto-launch configuration
# Based on the add_coder script but more generic

require 'optparse'
require 'open3'
require 'fileutils'

class AddAUser
  def initialize
    @username = ""
    @password = ""
    @vscode_port = "8080"
    @vscode_host = "0.0.0.0"
  end

  def show_usage
    puts "Usage: #{$0} [OPTIONS]"
    puts ""
    puts "Required Options:"
    puts "  --username USERNAME    Set the username (required)"
    puts "  --password PASSWORD    Set the password (required)"
    puts "  --port PORT           Set VS Code port (default: 8080)"
    puts "  --host HOST           Set VS Code host (default: 0.0.0.0)"
    puts "  --help                Show this help message"
    puts ""
    puts "Examples:"
    puts "  #{$0} --username testuser --password 1234"
  end

  def parse_arguments
    OptionParser.new do |opts|
      opts.banner = "Usage: #{$0} [OPTIONS]"

      opts.on("--username USERNAME", "Set the username (required)") do |username|
        @username = username
      end

      opts.on("--password PASSWORD", "Set the password (required)") do |password|
        @password = password
      end

      opts.on("--port PORT", "Set VS Code port") do |port|
        @vscode_port = port
      end

      opts.on("--host HOST", "Set VS Code host") do |host|
        @vscode_host = host
      end

      opts.on("-h", "--help", "Show this help message") do
        show_usage
        exit 0
      end
    end.parse!

    # Validate required arguments
    if @username.empty? || @password.empty?
      puts "Error: --username and --password are required"
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

  def create_user
    puts "Creating user: #{@username}"
    
    # Create user with home directory
    run_command("useradd -m -s /bin/bash #{@username}")
    
    # Set password
    run_command("echo '#{@username}:#{@password}' | chpasswd")
    
    puts "User #{@username} created successfully"
  end

  def configure_user_environment
    user_home = "/home/#{@username}"
    
    # Get display number
    display_num = run_command("/usr/local/bin/get_display").chomp
    
    # Configure applications
    run_command("/usr/local/bin/config_apps --username #{@username} --port #{@vscode_port} --host #{@vscode_host} --display #{display_num}")
    
    # Create a basic bashrc
    bashrc_content = <<~BASH
      # ~/.bashrc: executed by bash(1) for non-login shells.

      # If not running interactively, don't do anything
      case $- in
          *i*) ;;
          *) return;;
      esac

      # Don't put duplicate lines or lines starting with space in the history.
      HISTCONTROL=ignoreboth

      # Append to the history file, don't overwrite it
      shopt -s histappend

      # For setting history length see HISTSIZE and HISTFILESIZE in bash(1)
      HISTSIZE=1000
      HISTFILESIZE=2000

      # Check the window size after each command and, if necessary,
      # update the values of LINES and COLUMNS.
      shopt -s checkwinsize
    BASH

    File.write("#{user_home}/.bashrc", bashrc_content)
    
    # Add welcome message to bashrc
    welcome_message = <<~BASH

      # Welcome message
      echo "Welcome, #{@username}!"
    BASH

    File.open("#{user_home}/.bashrc", "a") { |f| f.write(welcome_message) }
    
    # Set ownership
    run_command("chown -R #{@username}:#{@username} #{user_home}")
    
    # Run additional setup scripts
    run_command("add_user_dirs --user #{@username}")
    run_command("set_firefox_profile --user #{@username}")
    run_command("setup_firefox_bashrc --user #{@username}")
    run_command("set_keyboard --user #{@username}")
    run_command("setup-desktop-shortcuts.sh --user #{@username}")
    run_command("configure-firefox-profile.sh --user #{@username}")
  end

  def main
    parse_arguments
    
    create_user
    configure_user_environment
    
    puts "User created successfully!"
    puts ""
    puts "- Desktop shortcuts for all applications (VS Code, Firefox, Git tools)"
  end
end

# Run the script
AddAUser.new.main
