# frozen_string_literal: true

module LubuntuGui
  # Manages window operations using Openbox window manager
  class WindowManager
    class << self
      # List all open windows
      #
      # @return [Array<Hash>] Array of window information
      def list_windows
        if command_available?("wmctrl")
          list_windows_wmctrl
        elsif command_available?("xdotool")
          list_windows_xdotool
        else
          raise CommandError, "Neither wmctrl nor xdotool is available"
        end
      end

      # Focus a specific window
      #
      # @param window_id [String] Window ID
      # @return [Boolean] true if successful
      def focus_window(window_id)
        if command_available?("wmctrl")
          result = CommandExecutor.safe_execute("wmctrl -i -a #{window_id}")
          result[:success]
        elsif command_available?("xdotool")
          result = CommandExecutor.safe_execute("xdotool windowactivate #{window_id}")
          result[:success]
        else
          false
        end
      end

      # Move a window to specific coordinates
      #
      # @param window_id [String] Window ID
      # @param x [Integer] X coordinate
      # @param y [Integer] Y coordinate
      # @return [Boolean] true if successful
      def move_window(window_id, x, y)
        if command_available?("wmctrl")
          result = CommandExecutor.safe_execute("wmctrl -i -r #{window_id} -e 0,#{x},#{y},-1,-1")
          result[:success]
        elsif command_available?("xdotool")
          result = CommandExecutor.safe_execute("xdotool windowmove #{window_id} #{x} #{y}")
          result[:success]
        else
          false
        end
      end

      # Resize a window
      #
      # @param window_id [String] Window ID
      # @param width [Integer] Width in pixels
      # @param height [Integer] Height in pixels
      # @return [Boolean] true if successful
      def resize_window(window_id, width, height)
        if command_available?("wmctrl")
          result = CommandExecutor.safe_execute("wmctrl -i -r #{window_id} -e 0,-1,-1,#{width},#{height}")
          result[:success]
        elsif command_available?("xdotool")
          result = CommandExecutor.safe_execute("xdotool windowsize #{window_id} #{width} #{height}")
          result[:success]
        else
          false
        end
      end

      # Minimize a window
      #
      # @param window_id [String] Window ID
      # @return [Boolean] true if successful
      def minimize_window(window_id)
        if command_available?("xdotool")
          result = CommandExecutor.safe_execute("xdotool windowminimize #{window_id}")
          result[:success]
        elsif command_available?("wmctrl")
          # wmctrl doesn't have direct minimize, use iconify
          result = CommandExecutor.safe_execute("wmctrl -i -r #{window_id} -b add,hidden")
          result[:success]
        else
          false
        end
      end

      # Maximize a window
      #
      # @param window_id [String] Window ID
      # @return [Boolean] true if successful
      def maximize_window(window_id)
        if command_available?("wmctrl")
          result = CommandExecutor.safe_execute("wmctrl -i -r #{window_id} -b add,maximized_vert,maximized_horz")
          result[:success]
        elsif command_available?("xdotool")
          # xdotool doesn't have direct maximize, simulate key press
          focus_window(window_id)
          result = CommandExecutor.safe_execute("xdotool key --window #{window_id} alt+F10")
          result[:success]
        else
          false
        end
      end

      # Close a window
      #
      # @param window_id [String] Window ID
      # @return [Boolean] true if successful
      def close_window(window_id)
        if command_available?("wmctrl")
          result = CommandExecutor.safe_execute("wmctrl -i -c #{window_id}")
          result[:success]
        elsif command_available?("xdotool")
          result = CommandExecutor.safe_execute("xdotool windowclose #{window_id}")
          result[:success]
        else
          false
        end
      end

      # Switch to a virtual desktop
      #
      # @param desktop_number [Integer] Desktop number (0-based)
      # @return [Boolean] true if successful
      def switch_desktop(desktop_number)
        if command_available?("wmctrl")
          result = CommandExecutor.safe_execute("wmctrl -s #{desktop_number}")
          result[:success]
        elsif command_available?("xdotool")
          result = CommandExecutor.safe_execute("xdotool set_desktop #{desktop_number}")
          result[:success]
        else
          false
        end
      end

      # Move window to a virtual desktop
      #
      # @param window_id [String] Window ID
      # @param desktop_number [Integer] Desktop number (0-based)
      # @return [Boolean] true if successful
      def move_window_to_desktop(window_id, desktop_number)
        if command_available?("wmctrl")
          result = CommandExecutor.safe_execute("wmctrl -i -r #{window_id} -t #{desktop_number}")
          result[:success]
        elsif command_available?("xdotool")
          result = CommandExecutor.safe_execute("xdotool windowmove #{window_id} #{desktop_number}")
          result[:success]
        else
          false
        end
      end

      # List virtual desktops
      #
      # @return [Array<Hash>] Array of desktop information
      def list_desktops
        if command_available?("wmctrl")
          result = CommandExecutor.safe_execute("wmctrl -d")
          return [] unless result[:success]

          result[:stdout].split("\n").map do |line|
            parts = line.split(/\s+/)
            {
              number: parts[0].to_i,
              active: parts[1] == "*",
              name: parts[8..-1]&.join(" ") || "Desktop #{parts[0]}"
            }
          end
        else
          []
        end
      end

      # Get current desktop
      #
      # @return [Integer] Current desktop number
      def current_desktop
        if command_available?("wmctrl")
          result = CommandExecutor.safe_execute("wmctrl -d")
          return 0 unless result[:success]

          current_line = result[:stdout].split("\n").find { |line| line.include?("*") }
          return 0 unless current_line

          current_line.split(/\s+/)[0].to_i
        else
          0
        end
      end

      # Set window layer (always on top, normal, always on bottom)
      #
      # @param window_id [String] Window ID
      # @param layer [Symbol] Layer (:above, :normal, :below)
      # @return [Boolean] true if successful
      def set_window_layer(window_id, layer)
        return false unless command_available?("wmctrl")

        case layer
        when :above
          result = CommandExecutor.safe_execute("wmctrl -i -r #{window_id} -b add,above")
        when :below
          result = CommandExecutor.safe_execute("wmctrl -i -r #{window_id} -b add,below")
        when :normal
          result1 = CommandExecutor.safe_execute("wmctrl -i -r #{window_id} -b remove,above")
          result2 = CommandExecutor.safe_execute("wmctrl -i -r #{window_id} -b remove,below")
          return result1[:success] && result2[:success]
        else
          return false
        end

        result[:success]
      end

      # Get window information
      #
      # @param window_id [String] Window ID
      # @return [Hash, nil] Window information or nil if not found
      def window_info(window_id)
        windows = list_windows
        windows.find { |w| w[:id] == window_id }
      end

      # Find windows by title
      #
      # @param title [String] Window title (can be partial)
      # @return [Array<Hash>] Array of matching windows
      def find_windows_by_title(title)
        windows = list_windows
        windows.select { |w| w[:title].downcase.include?(title.downcase) }
      end

      # Find windows by class
      #
      # @param window_class [String] Window class
      # @return [Array<Hash>] Array of matching windows
      def find_windows_by_class(window_class)
        windows = list_windows
        windows.select { |w| w[:class]&.downcase&.include?(window_class.downcase) }
      end

      private

      # Check if a command is available
      #
      # @param command [String] Command name
      # @return [Boolean] true if command is available
      def command_available?(command)
        CommandExecutor.command_exists?(command)
      end

      # List windows using wmctrl
      #
      # @return [Array<Hash>] Array of window information
      def list_windows_wmctrl
        result = CommandExecutor.safe_execute("wmctrl -l -x")
        return [] unless result[:success]

        result[:stdout].split("\n").map do |line|
          parts = line.split(/\s+/, 4)
          {
            id: parts[0],
            desktop: parts[1].to_i,
            class: parts[2],
            title: parts[3] || ""
          }
        end
      end

      # List windows using xdotool
      #
      # @return [Array<Hash>] Array of window information
      def list_windows_xdotool
        result = CommandExecutor.safe_execute("xdotool search --onlyvisible --name '.*'")
        return [] unless result[:success]

        window_ids = result[:stdout].split("\n")
        window_ids.map do |window_id|
          title_result = CommandExecutor.safe_execute("xdotool getwindowname #{window_id}")
          class_result = CommandExecutor.safe_execute("xdotool getwindowclassname #{window_id}")
          
          {
            id: window_id,
            desktop: 0, # xdotool doesn't easily provide desktop info
            class: class_result[:success] ? class_result[:stdout] : "",
            title: title_result[:success] ? title_result[:stdout] : ""
          }
        end
      end
    end
  end
end

