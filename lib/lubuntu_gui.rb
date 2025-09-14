# frozen_string_literal: true

require "active_support/inflector"
require_relative "lubuntu_gui/version"
require_relative "lubuntu_gui/command_executor"
require_relative "lubuntu_gui/catalog"
require_relative "lubuntu_gui/dbus_client"
require_relative "lubuntu_gui/configuration"
require_relative "lubuntu_gui/collector_base"
require_relative "lubuntu_gui/instance"
require_relative "lubuntu_gui/folder"
require_relative "lubuntu_gui/window_manager"
require_relative "lubuntu_gui/panel"
require_relative "lubuntu_gui/item_base"
require_relative "lubuntu_gui/application"
require_relative "lubuntu_gui/applications"
require_relative "lubuntu_gui/desktop"
require_relative "lubuntu_gui/system"
require_relative "lubuntu_gui/user"
require_relative "lubuntu_gui/users"
# LubuntuGui provides a comprehensive Ruby interface for managing Lubuntu desktop
# environment components including window management, panel configuration,
# application launching, desktop management, and system integration.
#
# @example Basic usage
#   # List all open windows
#   windows = LubuntuGui::WindowManager.list_windows
#
#   # Launch an application
#   LubuntuGui::Application.launch("firefox")
#
#   # Set desktop wallpaper
#   LubuntuGui::Desktop.set_wallpaper("/path/to/image.jpg")
#
#   # Send a notification
#   LubuntuGui::System.send_notification("Hello", "World!")
#
# @author Lubuntu GUI Team
# @since 1.0.0
module LubuntuGui
  class Error < StandardError; end
  class CommandError < Error; end
  class ConfigurationError < Error; end
  class WindowNotFoundError < Error; end
  class ApplicationNotFoundError < Error; end

  # Configure the LubuntuGui gem
  #
  # @yield [config] Configuration block
  # @yieldparam config [Configuration] Configuration object
  def self.configure
    yield(configuration) if block_given?
  end

  # Get the current configuration
  #
  # @return [Configuration] Current configuration
  def self.configuration
    @configuration ||= Configuration.new
  end

  # Reset configuration to defaults
  def self.reset_configuration!
    @configuration = Configuration.new
  end

  # Check if running on Lubuntu
  #
  # @return [Boolean] true if running on Lubuntu
  def self.lubuntu?
    desktop_session = ENV["DESKTOP_SESSION"]
    xdg_current_desktop = ENV["XDG_CURRENT_DESKTOP"]
    
    desktop_session&.downcase&.include?("lubuntu") ||
      xdg_current_desktop&.downcase&.include?("lxqt")
  end

  # Get the current desktop environment
  #
  # @return [String] Desktop environment name
  def self.desktop_environment
    ENV["XDG_CURRENT_DESKTOP"] || ENV["DESKTOP_SESSION"] || "unknown"
  end

  # Check if LXQt is available
  #
  # @return [Boolean] true if LXQt is available
  def self.lxqt_available?
    CommandExecutor.command_exists?("lxqt-config")
  end

  # Check if Openbox is available
  #
  # @return [Boolean] true if Openbox is available
  def self.openbox_available?
    CommandExecutor.command_exists?("openbox")
  end
end

