# frozen_string_literal: true

module LubuntuGui
  # Manages LXQt Panel configuration and widgets
  class Panel
    class << self
      # Configure panel settings
      #
      # @yield [config] Configuration block
      # @yieldparam config [PanelConfig] Panel configuration object
      def configure
        config = PanelConfig.new
        yield(config) if block_given?
        apply_configuration(config)
      end

      # Get current panel configuration
      #
      # @return [Hash] Current panel configuration
      def current_configuration
        config_data = LubuntuGui.configuration.read_lxqt_config("panel.conf")
        parse_panel_config(config_data)
      end

      # Add widget to panel
      #
      # @param widget_type [Symbol] Widget type (:clock, :volume, :network, etc.)
      # @param options [Hash] Widget options
      # @return [Boolean] true if successful
      def add_widget(widget_type, options = {})
        config_data = LubuntuGui.configuration.read_lxqt_config("panel.conf")
        
        # Find the next available plugin number
        plugin_num = find_next_plugin_number(config_data)
        plugin_section = "plugin_#{plugin_num}"
        
        # Add widget configuration
        config_data[plugin_section] = widget_configuration(widget_type, options)
        
        # Update plugin list
        update_plugin_list(config_data, plugin_num)
        
        # Write configuration
        LubuntuGui.configuration.write_lxqt_config("panel.conf", config_data)
        restart_panel
      end

      # Remove widget from panel
      #
      # @param widget_id [String] Widget ID or type
      # @return [Boolean] true if successful
      def remove_widget(widget_id)
        config_data = LubuntuGui.configuration.read_lxqt_config("panel.conf")
        
        # Find and remove the widget
        removed = false
        config_data.keys.each do |section|
          next unless section.start_with?("plugin_")
          
          if config_data[section]["type"] == widget_id.to_s
            config_data.delete(section)
            removed = true
            break
          end
        end
        
        return false unless removed
        
        # Renumber remaining plugins
        renumber_plugins(config_data)
        
        # Write configuration
        LubuntuGui.configuration.write_lxqt_config("panel.conf", config_data)
        restart_panel
      end

      # List current widgets
      #
      # @return [Array<Hash>] Array of widget information
      def list_widgets
        config_data = LubuntuGui.configuration.read_lxqt_config("panel.conf")
        widgets = []
        
        config_data.keys.sort.each do |section|
          next unless section.start_with?("plugin_")
          
          widget_config = config_data[section]
          widgets << {
            id: section,
            type: widget_config["type"],
            position: widget_config["position"] || "right",
            config: widget_config
          }
        end
        
        widgets
      end

      # Add application to quick launch
      #
      # @param application [String] Application name or desktop file
      # @return [Boolean] true if successful
      def add_to_quicklaunch(application)
        desktop_file = find_desktop_file(application)
        return false unless desktop_file
        
        config_data = LubuntuGui.configuration.read_lxqt_config("panel.conf")
        
        # Find quicklaunch plugin
        quicklaunch_section = find_quicklaunch_section(config_data)
        return false unless quicklaunch_section
        
        # Add to apps list
        current_apps = config_data[quicklaunch_section]["apps"] || ""
        apps_list = current_apps.split(",").map(&:strip).reject(&:empty?)
        
        unless apps_list.include?(desktop_file)
          apps_list << desktop_file
          config_data[quicklaunch_section]["apps"] = apps_list.join(", ")
          
          LubuntuGui.configuration.write_lxqt_config("panel.conf", config_data)
          restart_panel
          return true
        end
        
        false
      end

      # Remove application from quick launch
      #
      # @param application [String] Application name or desktop file
      # @return [Boolean] true if successful
      def remove_from_quicklaunch(application)
        desktop_file = find_desktop_file(application)
        return false unless desktop_file
        
        config_data = LubuntuGui.configuration.read_lxqt_config("panel.conf")
        
        # Find quicklaunch plugin
        quicklaunch_section = find_quicklaunch_section(config_data)
        return false unless quicklaunch_section
        
        # Remove from apps list
        current_apps = config_data[quicklaunch_section]["apps"] || ""
        apps_list = current_apps.split(",").map(&:strip).reject(&:empty?)
        
        if apps_list.delete(desktop_file)
          config_data[quicklaunch_section]["apps"] = apps_list.join(", ")
          
          LubuntuGui.configuration.write_lxqt_config("panel.conf", config_data)
          restart_panel
          return true
        end
        
        false
      end

      # Get quick launch applications
      #
      # @return [Array<String>] Array of desktop file paths
      def quicklaunch_applications
        config_data = LubuntuGui.configuration.read_lxqt_config("panel.conf")
        quicklaunch_section = find_quicklaunch_section(config_data)
        return [] unless quicklaunch_section
        
        current_apps = config_data[quicklaunch_section]["apps"] || ""
        current_apps.split(",").map(&:strip).reject(&:empty?)
      end

      # Restart panel
      #
      # @return [Boolean] true if successful
      def restart_panel
        # Kill existing panel
        CommandExecutor.safe_execute("pkill lxqt-panel")
        sleep(1)
        
        # Start new panel
        result = CommandExecutor.safe_execute("lxqt-panel &")
        result[:success]
      end

      # Show/hide panel
      #
      # @param visible [Boolean] Panel visibility
      # @return [Boolean] true if successful
      def set_visibility(visible)
        if visible
          CommandExecutor.safe_execute("lxqt-panel &")
        else
          CommandExecutor.safe_execute("pkill lxqt-panel")
        end[:success]
      end

      # Check if panel is running
      #
      # @return [Boolean] true if panel is running
      def running?
        result = CommandExecutor.safe_execute("pgrep lxqt-panel")
        result[:success]
      end

      private

      # Apply panel configuration
      #
      # @param config [PanelConfig] Panel configuration
      def apply_configuration(config)
        config_data = LubuntuGui.configuration.read_lxqt_config("panel.conf")
        
        # Update general panel settings
        config_data["General"] ||= {}
        config_data["General"]["position"] = config.position.to_s if config.position
        config_data["General"]["iconSize"] = config.size.to_s if config.size
        config_data["General"]["autoHide"] = config.auto_hide.to_s if config.auto_hide
        
        LubuntuGui.configuration.write_lxqt_config("panel.conf", config_data)
        restart_panel
      end

      # Parse panel configuration
      #
      # @param config_data [Hash] Raw configuration data
      # @return [Hash] Parsed configuration
      def parse_panel_config(config_data)
        general = config_data["General"] || {}
        {
          position: general["position"] || "bottom",
          size: general["iconSize"]&.to_i || 32,
          auto_hide: general["autoHide"] == "true"
        }
      end

      # Find next available plugin number
      #
      # @param config_data [Hash] Configuration data
      # @return [Integer] Next plugin number
      def find_next_plugin_number(config_data)
        plugin_numbers = config_data.keys
                                   .select { |k| k.start_with?("plugin_") }
                                   .map { |k| k.split("_")[1].to_i }
        
        plugin_numbers.empty? ? 1 : plugin_numbers.max + 1
      end

      # Get widget configuration
      #
      # @param widget_type [Symbol] Widget type
      # @param options [Hash] Widget options
      # @return [Hash] Widget configuration
      def widget_configuration(widget_type, options)
        base_config = { "type" => widget_type.to_s }
        
        case widget_type
        when :clock
          base_config.merge({
            "format" => options[:format] || "hh:mm",
            "showDate" => (options[:show_date] || false).to_s
          })
        when :volume
          base_config.merge({
            "device" => options[:device] || "default"
          })
        when :network
          base_config
        when :battery
          base_config
        else
          base_config.merge(options.transform_keys(&:to_s))
        end
      end

      # Update plugin list in configuration
      #
      # @param config_data [Hash] Configuration data
      # @param plugin_num [Integer] Plugin number to add
      def update_plugin_list(config_data, plugin_num)
        general = config_data["General"] ||= {}
        plugins = general["plugins"] || ""
        plugin_list = plugins.split(",").map(&:strip).reject(&:empty?)
        
        plugin_list << "plugin_#{plugin_num}"
        general["plugins"] = plugin_list.join(", ")
      end

      # Renumber plugins after removal
      #
      # @param config_data [Hash] Configuration data
      def renumber_plugins(config_data)
        # Get all plugin sections
        plugin_sections = config_data.keys.select { |k| k.start_with?("plugin_") }
        plugin_configs = plugin_sections.map { |s| [s, config_data.delete(s)] }
        
        # Renumber and re-add
        plugin_configs.each_with_index do |(old_section, config), index|
          new_section = "plugin_#{index + 1}"
          config_data[new_section] = config
        end
        
        # Update plugin list
        general = config_data["General"] ||= {}
        plugin_list = (1..plugin_configs.length).map { |i| "plugin_#{i}" }
        general["plugins"] = plugin_list.join(", ")
      end

      # Find desktop file for application
      #
      # @param application [String] Application name
      # @return [String, nil] Desktop file path
      def find_desktop_file(application)
        # If it's already a desktop file path, return it
        return application if application.end_with?(".desktop") && File.exist?(application)
        
        # Search in desktop entry directories
        LubuntuGui.configuration.desktop_entry_dirs.each do |dir|
          desktop_file = File.join(dir, "#{application}.desktop")
          return desktop_file if File.exist?(desktop_file)
        end
        
        nil
      end

      # Find quicklaunch section in configuration
      #
      # @param config_data [Hash] Configuration data
      # @return [String, nil] Quicklaunch section name
      def find_quicklaunch_section(config_data)
        config_data.keys.find do |section|
          section.start_with?("plugin_") && 
            config_data[section]["type"] == "quicklaunch"
        end
      end
    end

    # Panel configuration helper class
    class PanelConfig
      attr_accessor :position, :size, :auto_hide

      def initialize
        @position = nil
        @size = nil
        @auto_hide = nil
      end
    end
  end
end

