# frozen_string_literal: true

module LubuntuGui
  # Manages desktop environment and virtual desktops
  class Desktop
    class << self
      # Set desktop wallpaper
      #
      # @param image_path [String] Path to wallpaper image
      # @return [Boolean] true if successful
      def set_wallpaper(image_path)
        return false unless File.exist?(image_path)
        
        # Try different wallpaper setting methods
        methods = [
          "pcmanfm --set-wallpaper='#{image_path}'",
          "feh --bg-scale '#{image_path}'",
          "nitrogen --set-scaled '#{image_path}'",
          "gsettings set org.gnome.desktop.background picture-uri 'file://#{image_path}'"
        ]
        
        methods.each do |method|
          command = method.split.first
          next unless CommandExecutor.command_exists?(command)
          
          result = CommandExecutor.safe_execute(method)
          return true if result[:success]
        end
        
        false
      end

      # Get current wallpaper
      #
      # @return [String, nil] Current wallpaper path
      def get_wallpaper
        # Try to get from LXQt configuration
        config = LubuntuGui.configuration.read_lxqt_config("desktop.conf")
        wallpaper = config.dig("General", "wallpaper")
        return wallpaper if wallpaper && File.exist?(wallpaper)
        
        # Try other methods
        methods = [
          "gsettings get org.gnome.desktop.background picture-uri",
          "nitrogen --print-wallpaper"
        ]
        
        methods.each do |method|
          command = method.split.first
          next unless CommandExecutor.command_exists?(command)
          
          result = CommandExecutor.safe_execute(method)
          next unless result[:success]
          
          # Parse output
          output = result[:stdout].strip
          if output.start_with?("'file://")
            return output.gsub(/^'file:\/\/|'$/, "")
          elsif output.start_with?("file://")
            return output.gsub(/^file:\/\//, "")
          elsif File.exist?(output)
            return output
          end
        end
        
        nil
      end

      # Create desktop icon
      #
      # @param name [String] Icon name
      # @param command [String] Command to execute
      # @param icon_path [String] Icon image path
      # @return [Boolean] true if successful
      def create_desktop_icon(name, command, icon_path)
        Application.create_desktop_icon(name, command, icon_path)
      end

      # Remove desktop icon
      #
      # @param name [String] Icon name
      # @return [Boolean] true if successful
      def remove_desktop_icon(name)
        Application.remove_desktop_icon(name)
      end

      # List desktop icons
      #
      # @return [Array<String>] Array of desktop icon names
      def list_desktop_icons
        desktop_dir = File.join(ENV["HOME"], "Desktop")
        return [] unless Dir.exist?(desktop_dir)
        
        Dir.glob(File.join(desktop_dir, "*.desktop")).map do |file|
          File.basename(file, ".desktop")
        end
      end

      # Switch to virtual desktop
      #
      # @param desktop_number [Integer] Desktop number (0-based)
      # @return [Boolean] true if successful
      def switch_to(desktop_number)
        WindowManager.switch_desktop(desktop_number)
      end

      # Create new virtual desktop
      #
      # @return [Boolean] true if successful
      def create_desktop
        # LXQt doesn't support dynamic desktop creation via command line
        # This would require modifying window manager configuration
        false
      end

      # Remove virtual desktop
      #
      # @param desktop_number [Integer] Desktop number
      # @return [Boolean] true if successful
      def remove_desktop(desktop_number)
        # LXQt doesn't support dynamic desktop removal via command line
        # This would require modifying window manager configuration
        false
      end

      # Get number of virtual desktops
      #
      # @return [Integer] Number of desktops
      def desktop_count
        desktops = WindowManager.list_desktops
        desktops.length
      end

      # Get current desktop number
      #
      # @return [Integer] Current desktop number
      def current_desktop
        WindowManager.current_desktop
      end

      # Set desktop theme
      #
      # @param theme_name [String] Theme name
      # @return [Boolean] true if successful
      def set_theme(theme_name)
        begin
          LubuntuGui.configuration.set_theme(theme_name)
          restart_desktop_components
          true
        rescue ConfigurationError
          false
        end
      end

      # Get current theme
      #
      # @return [String] Current theme name
      def current_theme
        LubuntuGui.configuration.current_theme
      end

      # Set icon theme
      #
      # @param theme_name [String] Icon theme name
      # @return [Boolean] true if successful
      def set_icon_theme(theme_name)
        begin
          LubuntuGui.configuration.set_icon_theme(theme_name)
          restart_desktop_components
          true
        rescue ConfigurationError
          false
        end
      end

      # Get current icon theme
      #
      # @return [String] Current icon theme name
      def current_icon_theme
        LubuntuGui.configuration.current_icon_theme
      end

      # List available themes
      #
      # @return [Array<String>] Array of theme names
      def list_themes
        theme_dirs = [
          "/usr/share/themes",
          File.join(ENV["HOME"], ".themes"),
          File.join(ENV["HOME"], ".local/share/themes")
        ]
        
        themes = []
        theme_dirs.each do |dir|
          next unless Dir.exist?(dir)
          
          Dir.entries(dir).each do |entry|
            theme_path = File.join(dir, entry)
            next unless Dir.exist?(theme_path)
            next if entry.start_with?(".")
            
            # Check if it's a valid theme (has required files)
            if valid_theme?(theme_path)
              themes << entry
            end
          end
        end
        
        themes.uniq.sort
      end

      # List available icon themes
      #
      # @return [Array<String>] Array of icon theme names
      def list_icon_themes
        icon_dirs = LubuntuGui.configuration.icon_theme_dirs
        
        themes = []
        icon_dirs.each do |dir|
          next unless Dir.exist?(dir)
          
          Dir.entries(dir).each do |entry|
            theme_path = File.join(dir, entry)
            next unless Dir.exist?(theme_path)
            next if entry.start_with?(".")
            
            # Check if it's a valid icon theme
            if valid_icon_theme?(theme_path)
              themes << entry
            end
          end
        end
        
        themes.uniq.sort
      end

      # Get screen resolution
      #
      # @return [Hash] Screen resolution information
      def screen_resolution
        if CommandExecutor.command_exists?("xrandr")
          result = CommandExecutor.safe_execute("xrandr | grep '*' | head -1")
          if result[:success]
            match = result[:stdout].match(/(\d+)x(\d+)/)
            if match
              return {
                width: match[1].to_i,
                height: match[2].to_i
              }
            end
          end
        end
        
        { width: 1920, height: 1080 } # Default fallback
      end

      # Set screen resolution
      #
      # @param width [Integer] Screen width
      # @param height [Integer] Screen height
      # @return [Boolean] true if successful
      def set_screen_resolution(width, height)
        return false unless CommandExecutor.command_exists?("xrandr")
        
        # Get primary display
        result = CommandExecutor.safe_execute("xrandr | grep ' connected primary'")
        return false unless result[:success]
        
        display = result[:stdout].split.first
        return false unless display
        
        # Set resolution
        result = CommandExecutor.safe_execute("xrandr --output #{display} --mode #{width}x#{height}")
        result[:success]
      end

      # Lock screen
      #
      # @return [Boolean] true if successful
      def lock_screen
        lock_commands = [
          "lxqt-leave --lockscreen",
          "dm-tool lock",
          "loginctl lock-session",
          "xscreensaver-command -lock",
          "gnome-screensaver-command --lock"
        ]
        
        lock_commands.each do |command|
          cmd = command.split.first
          next unless CommandExecutor.command_exists?(cmd)
          
          result = CommandExecutor.safe_execute(command)
          return true if result[:success]
        end
        
        false
      end

      # Show desktop (minimize all windows)
      #
      # @return [Boolean] true if successful
      def show_desktop
        if CommandExecutor.command_exists?("wmctrl")
          result = CommandExecutor.safe_execute("wmctrl -k on")
          result[:success]
        else
          false
        end
      end

      # Hide desktop (restore all windows)
      #
      # @return [Boolean] true if successful
      def hide_desktop
        if CommandExecutor.command_exists?("wmctrl")
          result = CommandExecutor.safe_execute("wmctrl -k off")
          result[:success]
        else
          false
        end
      end

      private

      # Check if directory contains a valid theme
      #
      # @param theme_path [String] Path to theme directory
      # @return [Boolean] true if valid theme
      def valid_theme?(theme_path)
        # Check for common theme files
        required_files = ["gtk-3.0", "gtk-2.0", "openbox-3"]
        required_files.any? { |file| Dir.exist?(File.join(theme_path, file)) }
      end

      # Check if directory contains a valid icon theme
      #
      # @param theme_path [String] Path to icon theme directory
      # @return [Boolean] true if valid icon theme
      def valid_icon_theme?(theme_path)
        index_file = File.join(theme_path, "index.theme")
        File.exist?(index_file)
      end

      # Restart desktop components to apply theme changes
      def restart_desktop_components
        # Restart panel to apply theme
        Panel.restart_panel
        
        # Restart file manager if running
        if CommandExecutor.safe_execute("pgrep pcmanfm-qt")[:success]
          CommandExecutor.safe_execute("pkill pcmanfm-qt")
          sleep(1)
          CommandExecutor.safe_execute("pcmanfm-qt --desktop &")
        end
      end
    end
  end
end

