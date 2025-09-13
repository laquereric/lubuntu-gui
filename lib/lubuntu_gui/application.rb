# frozen_string_literal: true

module LubuntuGui

  
  # Manages application launching and desktop integration
  class Application < ItemBase
    attr_accessor :desktop_entry

    def initialize(source_file:)
      super
    end
    
    class << self
      # Launch an application by name
      #
      # @param application_name [String] Application name
      # @return [Boolean] true if successful
      def launch(application_name)
        desktop_file = find_desktop_file(application_name)
        
        if desktop_file
          launch_desktop_file(desktop_file)
        else
          # Try to launch as command
          launch_command(application_name)
        end
      end

      # Launch application using command
      #
      # @param command [String] Command to execute
      # @return [Boolean] true if successful
      def launch_command(command)
        begin
          pid = CommandExecutor.execute_async(command)
          pid.is_a?(Integer)
        rescue StandardError
          false
        end
      end

      # Launch application from desktop file
      #
      # @param desktop_file [String] Path to desktop file
      # @return [Boolean] true if successful
      def launch_desktop_file(desktop_file)
        return false unless File.exist?(desktop_file)
        
        result = CommandExecutor.safe_execute("gtk-launch #{File.basename(desktop_file, '.desktop')}")
        result[:success]
      end

      # List installed applications
      #
      # @return [Array<Hash>] Array of application information
      def list_installed
        applications = []
        
        LubuntuGui.configuration.desktop_entry_dirs.each do |dir|
          next unless Dir.exist?(dir)
          
          Dir.glob(File.join(dir, "*.desktop")).each do |desktop_file|
            app_info = parse_desktop_file(desktop_file)
            applications << app_info if app_info && !app_info[:hidden]
          end
        end
        
        # Remove duplicates (prefer user applications over system)
        applications.uniq { |app| app[:name] }
      end

      # Find application by name
      #
      # @param name [String] Application name
      # @return [Hash, nil] Application information
      def find_by_name(name)
        list_installed.find { |app| app[:name].downcase.include?(name.downcase) }
      end

      # Check if application is running
      #
      # @param application_name [String] Application name
      # @return [Boolean] true if running
      def is_running?(application_name)
        processes = CommandExecutor.get_processes(application_name)
        !processes.empty?
      end

      # Get running applications
      #
      # @return [Array<Hash>] Array of running application information
      def list_running
        windows = WindowManager.list_windows
        windows.map do |window|
          {
            name: window[:title],
            class: window[:class],
            window_id: window[:id],
            desktop: window[:desktop]
          }
        end.uniq { |app| app[:class] }
      end

      # Create desktop icon
      #
      # @param name [String] Application name
      # @param command [String] Command to execute
      # @param icon_path [String] Path to icon file
      # @param options [Hash] Additional options
      # @return [Boolean] true if successful
      def create_desktop_icon(name, command, icon_path, options = {})
        desktop_dir = File.join(ENV["HOME"], "Desktop")
        FileUtils.mkdir_p(desktop_dir) unless Dir.exist?(desktop_dir)
        
        desktop_file = File.join(desktop_dir, "#{name.gsub(/\s+/, '_')}.desktop")
        
        content = build_desktop_file_content(name, command, icon_path, options)
        
        begin
          File.write(desktop_file, content)
          File.chmod(0755, desktop_file)
          true
        rescue StandardError
          false
        end
      end

      # Remove desktop icon
      #
      # @param name [String] Application name
      # @return [Boolean] true if successful
      def remove_desktop_icon(name)
        desktop_dir = File.join(ENV["HOME"], "Desktop")
        desktop_file = File.join(desktop_dir, "#{name.gsub(/\s+/, '_')}.desktop")
        
        if File.exist?(desktop_file)
          File.delete(desktop_file)
          true
        else
          false
        end
      end

      # Add application to menu
      #
      # @param app_info [Hash] Application information
      # @return [Boolean] true if successful
      def add_to_menu(app_info)
        applications_dir = File.join(ENV["HOME"], ".local/share/applications")
        FileUtils.mkdir_p(applications_dir)
        
        desktop_file = File.join(applications_dir, "#{app_info[:name].gsub(/\s+/, '_')}.desktop")
        content = build_desktop_file_content(
          app_info[:name],
          app_info[:command],
          app_info[:icon],
          app_info
        )
        
        begin
          File.write(desktop_file, content)
          update_desktop_database
          true
        rescue StandardError
          false
        end
      end

      # Remove application from menu
      #
      # @param application_name [String] Application name
      # @return [Boolean] true if successful
      def remove_from_menu(application_name)
        applications_dir = File.join(ENV["HOME"], ".local/share/applications")
        desktop_file = File.join(applications_dir, "#{application_name.gsub(/\s+/, '_')}.desktop")
        
        if File.exist?(desktop_file)
          File.delete(desktop_file)
          update_desktop_database
          true
        else
          false
        end
      end

      # Get application categories
      #
      # @return [Array<String>] Array of available categories
      def categories
        apps = list_installed
        categories = apps.flat_map { |app| app[:categories] || [] }
        categories.uniq.sort
      end

      # List applications by category
      #
      # @param category [String] Category name
      # @return [Array<Hash>] Array of applications in category
      def list_by_category(category)
        apps = list_installed
        apps.select { |app| app[:categories]&.include?(category) }
      end

      # Search applications
      #
      # @param query [String] Search query
      # @return [Array<Hash>] Array of matching applications
      def search(query)
        apps = list_installed
        query_lower = query.downcase
        
        apps.select do |app|
          app[:name].downcase.include?(query_lower) ||
            app[:description]&.downcase&.include?(query_lower) ||
            app[:keywords]&.any? { |keyword| keyword.downcase.include?(query_lower) }
        end
      end

      private

      # Find desktop file for application
      #
      # @param application_name [String] Application name
      # @return [String, nil] Desktop file path
      def find_desktop_file(application_name)
        # Try exact match first
        LubuntuGui.configuration.desktop_entry_dirs.each do |dir|
          desktop_file = File.join(dir, "#{application_name}.desktop")
          return desktop_file if File.exist?(desktop_file)
        end
        
        # Try case-insensitive search
        LubuntuGui.configuration.desktop_entry_dirs.each do |dir|
          next unless Dir.exist?(dir)
          
          Dir.glob(File.join(dir, "*.desktop")).each do |desktop_file|
            basename = File.basename(desktop_file, ".desktop")
            return desktop_file if basename.downcase == application_name.downcase
          end
        end
        
        # Try searching by name in desktop files
        app = find_by_name(application_name)
        app ? app[:desktop_file] : nil
      end

      # Parse desktop file
      #
      # @param desktop_file [String] Path to desktop file
      # @return [Hash, nil] Application information
      def parse_desktop_file(desktop_file)
        return nil unless File.exist?(desktop_file)
        
        begin
          content = File.read(desktop_file)
          lines = content.split("\n")
          
          app_info = { desktop_file: desktop_file }
          in_desktop_entry = false
          
          lines.each do |line|
            line = line.strip
            next if line.empty? || line.start_with?("#")
            
            if line == "[Desktop Entry]"
              in_desktop_entry = true
              next
            elsif line.start_with?("[") && line.end_with?("]")
              in_desktop_entry = false
              next
            end
            
            next unless in_desktop_entry
            
            key, value = line.split("=", 2)
            next unless key && value
            
            case key
            when "Name"
              app_info[:name] = value
            when "Comment"
              app_info[:description] = value
            when "Exec"
              app_info[:command] = value.gsub(/%[fFuU]/, "").strip
            when "Icon"
              app_info[:icon] = value
            when "Categories"
              app_info[:categories] = value.split(";").reject(&:empty?)
            when "Keywords"
              app_info[:keywords] = value.split(";").reject(&:empty?)
            when "Hidden"
              app_info[:hidden] = value.downcase == "true"
            when "NoDisplay"
              app_info[:hidden] = value.downcase == "true"
            when "Type"
              app_info[:type] = value
            end
          end
          
          # Only return if it's an application
          return nil unless app_info[:type] == "Application"
          return nil if app_info[:name].nil? || app_info[:command].nil?
          
          app_info
        rescue StandardError
          nil
        end
      end

      # Build desktop file content
      #
      # @param name [String] Application name
      # @param command [String] Command to execute
      # @param icon_path [String] Icon path
      # @param options [Hash] Additional options
      # @return [String] Desktop file content
      def build_desktop_file_content(name, command, icon_path, options = {})
        content = "[Desktop Entry]\n"
        content += "Version=1.0\n"
        content += "Type=Application\n"
        content += "Name=#{name}\n"
        content += "Comment=#{options[:description] || name}\n"
        content += "Exec=#{command}\n"
        content += "Icon=#{icon_path}\n" if icon_path
        content += "Terminal=#{options[:terminal] || false}\n"
        content += "Categories=#{Array(options[:categories]).join(';')}\n" if options[:categories]
        content += "Keywords=#{Array(options[:keywords]).join(';')}\n" if options[:keywords]
        content += "StartupNotify=#{options[:startup_notify] || true}\n"
        content
      end

      # Update desktop database
      def update_desktop_database
        CommandExecutor.safe_execute("update-desktop-database ~/.local/share/applications")
      end
    end
  end
end

