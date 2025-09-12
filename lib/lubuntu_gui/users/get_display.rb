#!/usr/bin/env ruby

# Script to detect and return the correct display for X11 applications
# This script centralizes display detection logic used across multiple scripts

require 'optparse'
require 'open3'

class GetDisplay
  def initialize
    @default_display = ":0"
    @verbose = false
  end

  def show_usage
    puts "Usage: #{$0} [OPTIONS]"
    puts ""
    puts "Options:"
    puts "  --default DISPLAY     Set default display if none detected (default: :0)"
    puts "  --verbose             Enable verbose output"
    puts "  --help                Show this help message"
    puts ""
    puts "Examples:"
    puts "  #{$0}                    # Detect display, fallback to :0"
    puts "  #{$0} --default :1       # Detect display, fallback to :1"
    puts "  #{$0} --verbose          # Detect display with verbose output"
    puts ""
    puts "Output:"
    puts "  Returns the detected display (e.g., :0, :1, etc.)"
    puts "  Exit code 0 on success, 1 on error"
  end

  def parse_arguments
    OptionParser.new do |opts|
      opts.banner = "Usage: #{$0} [OPTIONS]"

      opts.on("--default DISPLAY", "Set default display if none detected") do |display|
        @default_display = display
      end

      opts.on("--verbose", "Enable verbose output") do
        @verbose = true
      end

      opts.on("-h", "--help", "Show this help message") do
        show_usage
        exit 0
      end
    end.parse!
  end

  def log_verbose(message)
    STDERR.puts message if @verbose
  end

  def detect_display
    detected_display = @default_display
    
    log_verbose "Starting display detection..."
    
    # First, check if DISPLAY environment variable is set
    if ENV['DISPLAY']
      detected_display = ENV['DISPLAY']
      log_verbose "Using DISPLAY environment variable: #{detected_display}"
    else
      log_verbose "DISPLAY environment variable not set, attempting Xorg detection..."
      
      # Try to detect active X display by looking for Xorg processes
      begin
        stdout, stderr, status = Open3.capture3("ps", "aux")
        if status.success?
          xorg_info = stdout.lines.grep(/Xorg.*:/).first
          
          if xorg_info
            log_verbose "Found Xorg process: #{xorg_info.chomp}"
            
            # Extract display number from Xorg process
            if match = xorg_info.match(/Xorg :(\d+)/)
              detected_display = ":#{match[1]}"
              log_verbose "Extracted display from Xorg process: #{detected_display}"
            else
              log_verbose "Could not extract display from Xorg process, using default"
            end
          else
            log_verbose "No Xorg processes found, using default display"
          end
        end
      rescue => e
        log_verbose "Error detecting Xorg processes: #{e.message}"
      end
    end
    
    detected_display
  end

  def main
    parse_arguments
    
    display = detect_display
    
    if display.nil? || display.empty?
      STDERR.puts "Error: Failed to detect display"
      exit 1
    end
    
    log_verbose "Final display: #{display}"
    puts display
  end
end

# Run the script
GetDisplay.new.main
