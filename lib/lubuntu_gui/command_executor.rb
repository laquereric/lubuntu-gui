# frozen_string_literal: true

require "open3"

module LubuntuGui
  # Handles command execution and system interaction
  class CommandExecutor
    class << self
      # Execute a command and return the result
      #
      # @param command [String] Command to execute
      # @param timeout [Integer] Timeout in seconds
      # @return [Hash] Result with stdout, stderr, and exit status
      # @raise [CommandError] If command fails
      def execute(command, timeout: 30)
        stdout, stderr, status = Open3.capture3(command, timeout: timeout)
        
        result = {
          stdout: stdout.strip,
          stderr: stderr.strip,
          success: status.success?,
          exit_code: status.exitstatus
        }

        unless result[:success]
          raise CommandError, "Command failed: #{command}\nError: #{stderr}"
        end

        result
      rescue Timeout::Error
        raise CommandError, "Command timed out: #{command}"
      end

      # Execute a command safely (doesn't raise on failure)
      #
      # @param command [String] Command to execute
      # @param timeout [Integer] Timeout in seconds
      # @return [Hash] Result with stdout, stderr, and exit status
      def safe_execute(command, timeout: 30)
        execute(command, timeout: timeout)
      rescue CommandError
        {
          stdout: "",
          stderr: "Command failed or timed out",
          success: false,
          exit_code: 1
        }
      end

      # Check if a command exists in the system
      #
      # @param command [String] Command name to check
      # @return [Boolean] true if command exists
      def command_exists?(command)
        result = safe_execute("which #{command}")
        result[:success]
      end

      # Get the output of a command
      #
      # @param command [String] Command to execute
      # @return [String] Command output
      def get_output(command)
        result = execute(command)
        result[:stdout]
      end

      # Execute a command in the background
      #
      # @param command [String] Command to execute
      # @return [Process] Process object
      def execute_async(command)
        Process.spawn(command)
      end

      # Kill a process by PID
      #
      # @param pid [Integer] Process ID
      # @param signal [String] Signal to send (default: TERM)
      def kill_process(pid, signal: "TERM")
        Process.kill(signal, pid)
      rescue Errno::ESRCH
        # Process doesn't exist
        false
      end

      # Get process information
      #
      # @param name [String] Process name
      # @return [Array<Hash>] Array of process information
      def get_processes(name)
        result = safe_execute("pgrep -f #{name}")
        return [] unless result[:success]

        pids = result[:stdout].split("\n").map(&:to_i)
        pids.map do |pid|
          {
            pid: pid,
            name: name,
            command: get_process_command(pid)
          }
        end
      end

      private

      # Get command line for a process
      #
      # @param pid [Integer] Process ID
      # @return [String] Process command line
      def get_process_command(pid)
        result = safe_execute("ps -p #{pid} -o cmd --no-headers")
        result[:success] ? result[:stdout] : ""
      end
    end
  end
end

