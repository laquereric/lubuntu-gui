# frozen_string_literal: true

require "inifile"
require "fileutils"

module LubuntuGui
  # Manages configuration for LubuntuGui and system settings
  class Communities
    attr_accessor :debug, :timeout, :lxqt_config_path, :openbox_config_path

    def initialize
      @debug = false
      @timeout = 30
      @lxqt_config_path = default_lxqt_config_path
      @openbox_config_path = default_openbox_config_path
    end

    # Get LXQt configuration file path
    #
    # @param file [String] Configuration file name
    # @return [String] Full path to configuration file
    def lxqt_config_file(file)
      File.join(@lxqt_config_path, file)
    end

    # Get Openbox configuration file path
    #
    # @param file [String] Configuration file name
    # @return [String] Full path to configuration file
    def openbox_config_file(file)
      File.join(@openbox_config_path, file)
    end

    # Read LXQt configuration
    #
    # @param file [String] Configuration file name
    # @return [Hash] Configuration data
    def read_lxqt_config(file)
      config_file = lxqt_config_file(file)
      return {} unless File.exist?(config_file)

      begin
        ini = IniFile.load(config_file)
        ini.to_h
      rescue StandardError => e
        raise ConfigurationError, "Failed to read LXQt config #{file}: #{e.message}"
      end
    end

    # Write LXQt configuration
    #
    # @param file [String] Configuration file name
    # @param data [Hash] Configuration data
    def write_lxqt_config(file, data)
      config_file = lxqt_config_file(file)
      FileUtils.mkdir_p(File.dirname(config_file))

      begin
        ini = IniFile.new(filename: config_file)
        data.each do |section, values|
          values.each do |key, value|
            ini[section][key] = value
          end
        end
        ini.write
      rescue StandardError => e
        raise ConfigurationError, "Failed to write LXQt config #{file}: #{e.message}"
      end
    end

    # Read Openbox configuration (XML)
    #
    # @param file [String] Configuration file name
    # @return [Nokogiri::XML::Document] XML document
    def read_openbox_config(file)
      config_file = openbox_config_file(file)
      return nil unless File.exist?(config_file)

      begin
        require "nokogiri"
        Nokogiri::XML(File.read(config_file))
      rescue LoadError
        raise ConfigurationError, "Nokogiri gem required for XML configuration"
      rescue StandardError => e
        raise ConfigurationError, "Failed to read Openbox config #{file}: #{e.message}"
      end
    end

    # Write Openbox configuration (XML)
    #
    # @param file [String] Configuration file name
    # @param doc [Nokogiri::XML::Document] XML document
    def write_openbox_config(file, doc)
      config_file = openbox_config_file(file)
      FileUtils.mkdir_p(File.dirname(config_file))

      begin
        File.write(config_file, doc.to_xml)
      rescue StandardError => e
        raise ConfigurationError, "Failed to write Openbox config #{file}: #{e.message}"
      end
    end

    # Get desktop entry directories
    #
    # @return [Array<String>] List of desktop entry directories
    def desktop_entry_dirs
      [
        File.join(ENV["HOME"], ".local/share/applications"),
        "/usr/share/applications",
        "/usr/local/share/applications"
      ].select { |dir| Dir.exist?(dir) }
    end

    # Get icon theme directories
    #
    # @return [Array<String>] List of icon theme directories
    def icon_theme_dirs
      [
        File.join(ENV["HOME"], ".local/share/icons"),
        File.join(ENV["HOME"], ".icons"),
        "/usr/share/icons",
        "/usr/local/share/icons"
      ].select { |dir| Dir.exist?(dir) }
    end

    # Get current theme name
    #
    # @return [String] Current theme name
    def current_theme
      config = read_lxqt_config("lxqt.conf")
      config.dig("General", "theme") || "Arc"
    end

    # Set theme
    #
    # @param theme_name [String] Theme name
    def set_theme(theme_name)
      config = read_lxqt_config("lxqt.conf")
      config["General"] ||= {}
      config["General"]["theme"] = theme_name
      write_lxqt_config("lxqt.conf", config)
    end

    # Get current icon theme
    #
    # @return [String] Current icon theme name
    def current_icon_theme
      config = read_lxqt_config("lxqt.conf")
      config.dig("General", "icon_theme") || "Papirus"
    end

    # Set icon theme
    #
    # @param theme_name [String] Icon theme name
    def set_icon_theme(theme_name)
      config = read_lxqt_config("lxqt.conf")
      config["General"] ||= {}
      config["General"]["icon_theme"] = theme_name
      write_lxqt_config("lxqt.conf", config)
    end

    # Backup configuration
    #
    # @param backup_dir [String] Backup directory
    def backup_config(backup_dir)
      FileUtils.mkdir_p(backup_dir)
      
      # Backup LXQt config
      if Dir.exist?(@lxqt_config_path)
        FileUtils.cp_r(@lxqt_config_path, File.join(backup_dir, "lxqt"))
      end
      
      # Backup Openbox config
      if Dir.exist?(@openbox_config_path)
        FileUtils.cp_r(@openbox_config_path, File.join(backup_dir, "openbox"))
      end
    end

    # Restore configuration
    #
    # @param backup_dir [String] Backup directory
    def restore_config(backup_dir)
      # Restore LXQt config
      lxqt_backup = File.join(backup_dir, "lxqt")
      if Dir.exist?(lxqt_backup)
        FileUtils.rm_rf(@lxqt_config_path)
        FileUtils.cp_r(lxqt_backup, @lxqt_config_path)
      end
      
      # Restore Openbox config
      openbox_backup = File.join(backup_dir, "openbox")
      if Dir.exist?(openbox_backup)
        FileUtils.rm_rf(@openbox_config_path)
        FileUtils.cp_r(openbox_backup, @openbox_config_path)
      end
    end

    private

    # Get default LXQt configuration path
    #
    # @return [String] Default LXQt config path
    def default_lxqt_config_path
      File.join(ENV["HOME"], ".config", "lxqt")
    end

    # Get default Openbox configuration path
    #
    # @return [String] Default Openbox config path
    def default_openbox_config_path
      File.join(ENV["HOME"], ".config", "openbox")
    end
  end
end

