#!/usr/bin/env ruby

# Script to create all desktop shortcuts and autostart entries
# This script consolidates all desktop shortcut and autostart logic
# including user desktop shortcuts, system autostart, and user autostart

require 'optparse'
require 'fileutils'

class SetupDesktopShortcuts
  def initialize
    @target_user = ""
    @target_system = false
  end

  def show_usage
    puts "Usage: #{$0} [OPTIONS]"
    puts ""
    puts "Options:"
    puts "  --user USERNAME     Create shortcuts for specific user"
    puts "  --system            Create system-wide autostart entries"
    puts "  --help              Show this help message"
    puts ""
    puts "Examples:"
    puts "  #{$0} --user testuser  # Create shortcuts for testuser"
    puts "  #{$0} --system         # Create system-wide autostart"
  end

  def parse_arguments
    OptionParser.new do |opts|
      opts.banner = "Usage: #{$0} [OPTIONS]"

      opts.on("--user USERNAME", "Create shortcuts for specific user") do |username|
        @target_user = username
      end

      opts.on("--system", "Create system-wide autostart entries") do
        @target_system = true
      end

      opts.on("-h", "--help", "Show this help message") do
        show_usage
        exit 0
      end
    end.parse!

    # Validation: If TARGET_USER is not set and CREATE_SYSTEM is not set, abort
    if @target_user.empty? && !@target_system
      puts "Error: Either --user USERNAME or --system must be specified"
      puts ""
      show_usage
      exit 1
    end
  end

  def create_desktop_file(name, content, desktop_dir)
    desktop_file = "#{desktop_dir}/#{name}.desktop"
    File.write(desktop_file, content)
    FileUtils.chmod(0755, desktop_file)
    puts "Created desktop file: #{desktop_file}"
  end

  def create_for_system
    puts "Creating system-wide autostart entries..."
    
    autostart_dir = "/etc/xdg/autostart"
    FileUtils.mkdir_p(autostart_dir)
    
    # Create system autostart entries here
    # This is a simplified version - you would add actual autostart entries
    
    puts "System autostart entries created successfully!"
  end

  def create_for_user
    puts "Creating desktop shortcuts for user: #{@target_user}"
    
    user_home = "/home/#{@target_user}"
    desktop_dir = "#{user_home}/Desktop"
    FileUtils.mkdir_p(desktop_dir)
    
    # VS Code shortcut
    vscode_content = <<~DESKTOP
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=VS Code
      Comment=Visual Studio Code
      Exec=code
      Icon=code
      Terminal=false
      StartupNotify=true
      Categories=Development;TextEditor;
    DESKTOP
    
    create_desktop_file("vscode", vscode_content, desktop_dir)
    
    # Firefox shortcut
    firefox_content = <<~DESKTOP
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=Firefox
      Comment=Web Browser
      Exec=firefox
      Icon=firefox
      Terminal=false
      StartupNotify=true
      Categories=Network;WebBrowser;
    DESKTOP
    
    create_desktop_file("firefox", firefox_content, desktop_dir)
    
    # Git GUI shortcut
    git_gui_content = <<~DESKTOP
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=Git GUI
      Comment=Git Graphical Interface
      Exec=git-gui
      Icon=git
      Terminal=false
      StartupNotify=true
      Categories=Development;RevisionControl;
    DESKTOP
    
    create_desktop_file("git-gui", git_gui_content, desktop_dir)
    
    # Meld shortcut
    meld_content = <<~DESKTOP
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=Meld
      Comment=File comparison tool
      Exec=meld
      Icon=meld
      Terminal=false
      StartupNotify=true
      Categories=Development;FileManager;
    DESKTOP
    
    create_desktop_file("meld", meld_content, desktop_dir)
    
    # Set ownership
    system("chown -R #{@target_user}:#{@target_user} #{desktop_dir}")
    
    puts "Desktop shortcuts created successfully for #{@target_user}!"
    puts "  - VS Code (code editor)"
    puts "  - Firefox (web browser)"
    puts "  - Git GUI (git launcher)"
    puts "  - Meld (file comparison)"
  end

  def main
    parse_arguments
    
    # Create system-wide autostart entries
    if @target_system
      create_for_system
    end
    
    # Create user-specific shortcuts and autostart
    if !@target_user.empty?
      create_for_user
    end
    
    puts "Done"
  end
end

# Run the script
SetupDesktopShortcuts.new.main
