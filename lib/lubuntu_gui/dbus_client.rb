# frozen_string_literal: true

begin
  require "dbus"
rescue LoadError
  # D-Bus not available, provide fallback
  module DBus
    class Error < StandardError; end
  end
end

module LubuntuGui
  # Handles D-Bus communication for system services
  class DBusClient
    class << self
      # Send a notification via D-Bus
      #
      # @param title [String] Notification title
      # @param message [String] Notification message
      # @param icon [String, nil] Icon path or name
      # @param timeout [Integer] Timeout in milliseconds
      # @return [Boolean] true if successful
      def send_notification(title, message, icon: nil, timeout: 5000)
        return false unless dbus_available?

        begin
          bus = DBus::SessionBus.instance
          service = bus.service("org.freedesktop.Notifications")
          object = service.object("/org/freedesktop/Notifications")
          object.introspect
          
          interface = object["org.freedesktop.Notifications"]
          interface.Notify(
            "LubuntuGui",     # app_name
            0,                # replaces_id
            icon || "",       # app_icon
            title,            # summary
            message,          # body
            [],               # actions
            {},               # hints
            timeout           # timeout
          )
          true
        rescue DBus::Error, StandardError
          false
        end
      end

      # Get network manager status via D-Bus
      #
      # @return [Hash] Network status information
      def network_status
        return { available: false } unless dbus_available?

        begin
          bus = DBus::SystemBus.instance
          service = bus.service("org.freedesktop.NetworkManager")
          object = service.object("/org/freedesktop/NetworkManager")
          object.introspect
          
          interface = object["org.freedesktop.NetworkManager"]
          state = interface.State[0]
          
          {
            available: true,
            state: network_state_name(state),
            connected: state == 70 # NM_STATE_CONNECTED_GLOBAL
          }
        rescue DBus::Error, StandardError
          { available: false }
        end
      end

      # Control audio via PulseAudio D-Bus interface
      #
      # @param action [Symbol] Action to perform (:get_volume, :set_volume, :mute, :unmute)
      # @param value [Integer, nil] Volume value for set_volume
      # @return [Hash] Result of the operation
      def audio_control(action, value: nil)
        return { success: false, error: "D-Bus not available" } unless dbus_available?

        begin
          case action
          when :get_volume
            get_pulse_volume
          when :set_volume
            set_pulse_volume(value)
          when :mute
            set_pulse_mute(true)
          when :unmute
            set_pulse_mute(false)
          else
            { success: false, error: "Unknown action: #{action}" }
          end
        rescue DBus::Error, StandardError => e
          { success: false, error: e.message }
        end
      end

      # Check if D-Bus is available
      #
      # @return [Boolean] true if D-Bus is available
      def dbus_available?
        defined?(DBus::SessionBus) && !ENV["DBUS_SESSION_BUS_ADDRESS"].nil?
      end

      private

      # Convert NetworkManager state to readable name
      #
      # @param state [Integer] NetworkManager state
      # @return [String] State name
      def network_state_name(state)
        case state
        when 0 then "unknown"
        when 10 then "asleep"
        when 20 then "disconnected"
        when 30 then "disconnecting"
        when 40 then "connecting"
        when 50 then "connected_local"
        when 60 then "connected_site"
        when 70 then "connected_global"
        else "unknown"
        end
      end

      # Get PulseAudio volume
      #
      # @return [Hash] Volume information
      def get_pulse_volume
        # Fallback to command line if D-Bus interface not available
        result = CommandExecutor.safe_execute("pactl get-sink-volume @DEFAULT_SINK@")
        if result[:success]
          volume_match = result[:stdout].match(/(\d+)%/)
          volume = volume_match ? volume_match[1].to_i : 0
          { success: true, volume: volume }
        else
          { success: false, error: "Could not get volume" }
        end
      end

      # Set PulseAudio volume
      #
      # @param volume [Integer] Volume level (0-100)
      # @return [Hash] Operation result
      def set_pulse_volume(volume)
        volume = [[volume, 0].max, 100].min # Clamp between 0-100
        result = CommandExecutor.safe_execute("pactl set-sink-volume @DEFAULT_SINK@ #{volume}%")
        { success: result[:success] }
      end

      # Set PulseAudio mute state
      #
      # @param muted [Boolean] Mute state
      # @return [Hash] Operation result
      def set_pulse_mute(muted)
        state = muted ? "1" : "0"
        result = CommandExecutor.safe_execute("pactl set-sink-mute @DEFAULT_SINK@ #{state}")
        { success: result[:success] }
      end
    end
  end
end

