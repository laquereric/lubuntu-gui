#!/usr/bin/env ruby

# Script to create user directories for persistent profiles and data
# This script creates necessary directories for users to store persistent data

require 'optparse'
require 'fileutils'

class AddUserDirs
  def initialize
    @target_user = ""
    @create_all = false
  end

  def show_usage
    puts "Usage: #{$0} [OPTIONS]"
    puts ""
    puts "Options:"
    puts "  --user USERNAME     Create directories for specific user"
    puts "  --all               Create directories for all default users"
    puts "  --help              Show this help message"
    puts ""
    puts "Examples:"
    puts "  #{$0} --user testuser  # Create directories for testuser"
    puts "  #{$0} --all            # Create directories for all users"
    puts ""
    puts "Default users: testuser, coder"
  end

  def parse_arguments
    OptionParser.new do |opts|
      opts.banner = "Usage: #{$0} [OPTIONS]"

      opts.on("--user USERNAME", "Create directories for specific user") do |username|
        @target_user = username
      end

      opts.on("--all", "Create directories for all default users") do
        @create_all = true
      end

      opts.on("-h", "--help", "Show this help message") do
        show_usage
        exit 0
      end
    end.parse!
  end

  def create_user_dirs(username)
    user_home = "/home/#{username}"
    
    puts "Creating directories for user: #{username}"
    
    # Create user home directory if it doesn't exist
    unless Dir.exist?(user_home)
      puts "Warning: User home directory #{user_home} does not exist"
      return false
    end
    
    # Create Firefox state directory
    firefox_dir = "#{user_home}/firefox-state"
    FileUtils.mkdir_p(firefox_dir)
    FileUtils.chmod(0755, firefox_dir)
    begin
      system("chown #{username}:#{username} #{firefox_dir}")
    rescue
      # Ignore chown errors
    end
    
    # Create VS Code workspace directory
    vscode_dir = "#{user_home}/vscode-workspace"
    FileUtils.mkdir_p(vscode_dir)
    FileUtils.chmod(0755, vscode_dir)
    begin
      system("chown #{username}:#{username} #{vscode_dir}")
    rescue
      # Ignore chown errors
    end
    
    # Create desktop directory if it doesn't exist
    desktop_dir = "#{user_home}/Desktop"
    FileUtils.mkdir_p(desktop_dir)
    FileUtils.chmod(0755, desktop_dir)
    begin
      system("chown #{username}:#{username} #{desktop_dir}")
    rescue
      # Ignore chown errors
    end
    
    # Create documents directory if it doesn't exist
    docs_dir = "#{user_home}/Documents"
    FileUtils.mkdir_p(docs_dir)
    FileUtils.chmod(0755, docs_dir)
    begin
      system("chown #{username}:#{username} #{docs_dir}")
    rescue
      # Ignore chown errors
    end
    
    # Create downloads directory if it doesn't exist
    downloads_dir = "#{user_home}/Downloads"
    FileUtils.mkdir_p(downloads_dir)
    FileUtils.chmod(0755, downloads_dir)
    begin
      system("chown #{username}:#{username} #{downloads_dir}")
    rescue
      # Ignore chown errors
    end
    
    puts "✓ Created directories for #{username}:"
    puts "  - #{firefox_dir}"
    puts "  - #{vscode_dir}"
    puts "  - #{desktop_dir}"
    puts "  - #{docs_dir}"
    puts "  - #{downloads_dir}"
    
    true
  end

  def main
    puts "Creating user directories for persistent profiles..."
    parse_arguments
    
    if @create_all
      puts "Creating directories for all default users..."
      create_user_dirs("testuser")
      create_user_dirs("coder")
      puts "All user directories created successfully!"
    elsif !@target_user.empty?
      create_user_dirs(@target_user)
      puts "User directories created successfully!"
    else
      puts "Error: Must specify either --user USERNAME or --all"
      puts ""
      show_usage
      exit 1
    end
  end
end

# Run the script
AddUserDirs.new.main
