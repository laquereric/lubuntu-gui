# frozen_string_literal: true

module LubuntuGui
  # Manages system integration and services
  class System
    class << self
      # Set system volume
      #
      # @param level [Integer] Volume level (0-100)
      # @return [Boolean] true if successful
      def set_volume(level)
        level = [[level, 0].max, 100].min # Clamp between 0-100
        
        result = DBusClient.audio_control(:set_volume, value: level)
        result[:success]
      end

      # Get current volume
      #
      # @return [Integer] Current volume level (0-100)
      def get_volume
        result = DBusClient.audio_control(:get_volume)
        result[:success] ? result[:volume] : 0
      end

      # Mute audio
      #
      # @return [Boolean] true if successful
      def mute
        result = DBusClient.audio_control(:mute)
        result[:success]
      end

      # Unmute audio
      #
      # @return [Boolean] true if successful
      def unmute
        result = DBusClient.audio_control(:unmute)
        result[:success]
      end

      # Check if audio is muted
      #
      # @return [Boolean] true if muted
      def muted?
        if CommandExecutor.command_exists?("pactl")
          result = CommandExecutor.safe_execute("pactl get-sink-mute @DEFAULT_SINK@")
          result[:success] && result[:stdout].include?("yes")
        else
          false
        end
      end

      # Send notification
      #
      # @param title [String] Notification title
      # @param message [String] Notification message
      # @param icon [String, nil] Icon path or name
      # @param timeout [Integer] Timeout in milliseconds
      # @return [Boolean] true if successful
      def send_notification(title, message, icon: nil, timeout: 5000)
        # Try D-Bus first
        if DBusClient.send_notification(title, message, icon: icon, timeout: timeout)
          return true
        end
        
        # Fallback to notify-send
        if CommandExecutor.command_exists?("notify-send")
          cmd = "notify-send"
          cmd += " --icon='#{icon}'" if icon
          cmd += " --expire-time=#{timeout}"
          cmd += " '#{title}' '#{message}'"
          
          result = CommandExecutor.safe_execute(cmd)
          return result[:success]
        end
        
        false
      end

      # Clear all notifications
      #
      # @return [Boolean] true if successful
      def clear_notifications
        # This depends on the notification daemon
        # For LXQt, we can try to interact with the notification widget
        if CommandExecutor.command_exists?("pkill")
          result = CommandExecutor.safe_execute("pkill -USR1 lxqt-notificationd")
          result[:success]
        else
          false
        end
      end

      # Get network status
      #
      # @return [Hash] Network status information
      def network_status
        # Try D-Bus first
        dbus_status = DBusClient.network_status
        return dbus_status if dbus_status[:available]
        
        # Fallback to command line tools
        if CommandExecutor.command_exists?("nmcli")
          result = CommandExecutor.safe_execute("nmcli general status")
          if result[:success]
            connected = result[:stdout].include?("connected")
            return {
              available: true,
              connected: connected,
              state: connected ? "connected" : "disconnected"
            }
          end
        end
        
        # Basic connectivity check
        ping_result = CommandExecutor.safe_execute("ping -c 1 -W 2 8.8.8.8")
        {
          available: true,
          connected: ping_result[:success],
          state: ping_result[:success] ? "connected" : "disconnected"
        }
      end

      # List available networks
      #
      # @return [Array<Hash>] Array of network information
      def list_networks
        return [] unless CommandExecutor.command_exists?("nmcli")
        
        result = CommandExecutor.safe_execute("nmcli device wifi list")
        return [] unless result[:success]
        
        networks = []
        lines = result[:stdout].split("\n")[1..-1] # Skip header
        
        lines.each do |line|
          parts = line.strip.split(/\s+/)
          next if parts.length < 6
          
          networks << {
            ssid: parts[1],
            signal: parts[5].to_i,
            security: parts[6] || "none",
            connected: line.include?("*")
          }
        end
        
        networks
      end

      # Get battery status (for laptops)
      #
      # @return [Hash] Battery status information
      def battery_status
        battery_info = {
          available: false,
          charging: false,
          percentage: 0,
          time_remaining: nil
        }
        
        # Check for battery using upower
        if CommandExecutor.command_exists?("upower")
          result = CommandExecutor.safe_execute("upower -i $(upower -e | grep 'BAT')")
          if result[:success] && !result[:stdout].empty?
            battery_info[:available] = true
            
            # Parse upower output
            result[:stdout].split("\n").each do |line|
              case line.strip
              when /state:\s+(.+)/
                battery_info[:charging] = $1.include?("charging")
              when /percentage:\s+(\d+)%/
                battery_info[:percentage] = $1.to_i
              when /time to (?:empty|full):\s+(.+)/
                battery_info[:time_remaining] = $1
              end
            end
          end
        end
        
        # Fallback to /sys/class/power_supply
        if !battery_info[:available] && Dir.exist?("/sys/class/power_supply")
          Dir.glob("/sys/class/power_supply/BAT*").each do |bat_dir|
            next unless Dir.exist?(bat_dir)
            
            battery_info[:available] = true
            
            # Read capacity
            capacity_file = File.join(bat_dir, "capacity")
            if File.exist?(capacity_file)
              battery_info[:percentage] = File.read(capacity_file).strip.to_i
            end
            
            # Read status
            status_file = File.join(bat_dir, "status")
            if File.exist?(status_file)
              status = File.read(status_file).strip
              battery_info[:charging] = status.downcase.include?("charging")
            end
            
            break # Use first battery found
          end
        end
        
        battery_info
      end

      # Get system information
      #
      # @return [Hash] System information
      def system_info
        info = {
          os: "Unknown",
          kernel: "Unknown",
          desktop: LubuntuGui.desktop_environment,
          uptime: "Unknown",
          memory: {}
        }
        
        # Get OS information
        if File.exist?("/etc/os-release")
          os_release = File.read("/etc/os-release")
          if match = os_release.match(/PRETTY_NAME="([^"]+)"/)
            info[:os] = match[1]
          end
        end
        
        # Get kernel version
        if CommandExecutor.command_exists?("uname")
          result = CommandExecutor.safe_execute("uname -r")
          info[:kernel] = result[:stdout] if result[:success]
        end
        
        # Get uptime
        if CommandExecutor.command_exists?("uptime")
          result = CommandExecutor.safe_execute("uptime -p")
          info[:uptime] = result[:stdout] if result[:success]
        end
        
        # Get memory information
        if File.exist?("/proc/meminfo")
          meminfo = File.read("/proc/meminfo")
          
          if match = meminfo.match(/MemTotal:\s+(\d+) kB/)
            info[:memory][:total] = match[1].to_i * 1024 # Convert to bytes
          end
          
          if match = meminfo.match(/MemAvailable:\s+(\d+) kB/)
            info[:memory][:available] = match[1].to_i * 1024
          end
          
          if info[:memory][:total] && info[:memory][:available]
            info[:memory][:used] = info[:memory][:total] - info[:memory][:available]
            info[:memory][:percentage] = (info[:memory][:used].to_f / info[:memory][:total] * 100).round(1)
          end
        end
        
        info
      end

      # Get CPU usage
      #
      # @return [Float] CPU usage percentage
      def cpu_usage
        if CommandExecutor.command_exists?("top")
          result = CommandExecutor.safe_execute("top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | cut -d'%' -f1")
          if result[:success] && !result[:stdout].empty?
            return result[:stdout].to_f
          end
        end
        
        # Fallback method using /proc/stat
        if File.exist?("/proc/stat")
          # This is a simplified calculation
          stat1 = File.read("/proc/stat").split("\n")[0].split[1..-1].map(&:to_i)
          sleep(0.1)
          stat2 = File.read("/proc/stat").split("\n")[0].split[1..-1].map(&:to_i)
          
          idle1, idle2 = stat1[3], stat2[3]
          total1, total2 = stat1.sum, stat2.sum
          
          idle_diff = idle2 - idle1
          total_diff = total2 - total1
          
          return total_diff > 0 ? ((total_diff - idle_diff).to_f / total_diff * 100).round(1) : 0.0
        end
        
        0.0
      end

      # Get disk usage
      #
      # @param path [String] Path to check (default: home directory)
      # @return [Hash] Disk usage information
      def disk_usage(path = ENV["HOME"])
        if CommandExecutor.command_exists?("df")
          result = CommandExecutor.safe_execute("df -h '#{path}'")
          if result[:success]
            lines = result[:stdout].split("\n")
            return {} if lines.length < 2
            
            parts = lines[1].split
            return {
              total: parts[1],
              used: parts[2],
              available: parts[3],
              percentage: parts[4].to_i
            }
          end
        end
        
        {}
      end

      # Shutdown system
      #
      # @param delay [Integer] Delay in minutes (default: 0)
      # @return [Boolean] true if command was sent
      def shutdown(delay: 0)
        if CommandExecutor.command_exists?("shutdown")
          result = CommandExecutor.safe_execute("shutdown -h +#{delay}")
          result[:success]
        elsif CommandExecutor.command_exists?("systemctl")
          result = CommandExecutor.safe_execute("systemctl poweroff")
          result[:success]
        else
          false
        end
      end

      # Restart system
      #
      # @param delay [Integer] Delay in minutes (default: 0)
      # @return [Boolean] true if command was sent
      def restart(delay: 0)
        if CommandExecutor.command_exists?("shutdown")
          result = CommandExecutor.safe_execute("shutdown -r +#{delay}")
          result[:success]
        elsif CommandExecutor.command_exists?("systemctl")
          result = CommandExecutor.safe_execute("systemctl reboot")
          result[:success]
        else
          false
        end
      end

      # Logout current session
      #
      # @return [Boolean] true if command was sent
      def logout
        logout_commands = [
          "lxqt-leave --logout",
          "loginctl terminate-session $XDG_SESSION_ID",
          "pkill -KILL -u $USER"
        ]
        
        logout_commands.each do |command|
          cmd = command.split.first
          next unless CommandExecutor.command_exists?(cmd)
          
          result = CommandExecutor.safe_execute(command)
          return true if result[:success]
        end
        
        false
      end
    end
  end
end

