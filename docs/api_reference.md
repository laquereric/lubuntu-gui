# API Reference

This document provides a detailed reference for the LubuntuGui gem API. For a higher-level overview and usage examples, please see the [User Guide](user_guide.md).

## Top-Level Module: `LubuntuGui`

The `LubuntuGui` module is the main entry point for the gem. It provides access to all major components and configuration settings.

### Methods

- **`LubuntuGui.configure`**: Configures the gem with custom settings.
- **`LubuntuGui.configuration`**: Returns the current configuration object.
- **`LubuntuGui.reset_configuration!`**: Resets the configuration to default values.
- **`LubuntuGui.lubuntu?`**: Checks if the current environment is Lubuntu.
- **`LubuntuGui.desktop_environment`**: Returns the name of the current desktop environment.
- **`LubuntuGui.lxqt_available?`**: Checks if LXQt is available.
- **`LubuntuGui.openbox_available?`**: Checks if Openbox is available.

### Error Classes

- **`LubuntuGui::Error`**: Base error class for the gem.
- **`LubuntuGui::CommandError`**: Raised when a shell command fails.
- **`LubuntuGui::ConfigurationError`**: Raised for configuration-related errors.
- **`LubuntuGui::WindowNotFoundError`**: Raised when a window cannot be found.
- **`LubuntuGui::ApplicationNotFoundError`**: Raised when an application cannot be found.




## `LubuntuGui::WindowManager`

Manages window operations using the Openbox window manager. This class provides methods for listing, focusing, moving, resizing, and managing windows.

### Class Methods

- **`list_windows`**: Returns an array of hashes, each representing an open window.
- **`focus_window(window_id)`**: Activates a window by its ID.
- **`move_window(window_id, x, y)`**: Moves a window to the specified coordinates.
- **`resize_window(window_id, width, height)`**: Resizes a window to the given dimensions.
- **`minimize_window(window_id)`**: Minimizes a window.
- **`maximize_window(window_id)`**: Maximizes a window.
- **`close_window(window_id)`**: Closes a window.
- **`switch_desktop(desktop_number)`**: Switches to a different virtual desktop.
- **`move_window_to_desktop(window_id, desktop_number)`**: Moves a window to another desktop.
- **`list_desktops`**: Returns information about all virtual desktops.
- **`current_desktop`**: Returns the number of the currently active desktop.
- **`set_window_layer(window_id, layer)`**: Sets the window layer (e.g., `:above`, `:normal`, `:below`).
- **`window_info(window_id)`**: Returns detailed information about a specific window.
- **`find_windows_by_title(title)`**: Finds windows matching a given title.
- **`find_windows_by_class(window_class)`**: Finds windows matching a window class.




## `LubuntuGui::Panel`

Manages the LXQt panel, including its configuration, widgets, and quick launch items.

### Class Methods

- **`configure`**: Configures panel settings such as position, size, and auto-hide.
- **`current_configuration`**: Returns the current panel configuration.
- **`add_widget(widget_type, options)`**: Adds a new widget to the panel.
- **`remove_widget(widget_id)`**: Removes a widget from the panel.
- **`list_widgets`**: Returns a list of all widgets currently on the panel.
- **`add_to_quicklaunch(application)`**: Adds an application to the quick launch bar.
- **`remove_from_quicklaunch(application)`**: Removes an application from the quick launch bar.
- **`quicklaunch_applications`**: Returns a list of applications in the quick launch bar.
- **`restart_panel`**: Restarts the LXQt panel to apply changes.
- **`set_visibility(visible)`**: Shows or hides the panel.
- **`running?`**: Checks if the panel is currently running.




## `LubuntuGui::Application`

Manages application launching, desktop integration, and menu entries.

### Class Methods

- **`launch(application_name)`**: Launches an application by its name or desktop file.
- **`launch_command(command)`**: Executes a command to launch an application.
- **`launch_desktop_file(desktop_file)`**: Launches an application from its `.desktop` file.
- **`list_installed`**: Returns a list of all installed applications.
- **`find_by_name(name)`**: Finds an application by its name.
- **`is_running?(application_name)`**: Checks if an application is currently running.
- **`list_running`**: Returns a list of all running applications.
- **`create_desktop_icon(name, command, icon_path, options)`**: Creates a new desktop icon.
- **`remove_desktop_icon(name)`**: Removes a desktop icon.
- **`add_to_menu(app_info)`**: Adds an application to the main menu.
- **`remove_from_menu(application_name)`**: Removes an application from the main menu.
- **`categories`**: Returns a list of all available application categories.
- **`list_by_category(category)`**: Lists all applications in a specific category.
- **`search(query)`**: Searches for applications by name, description, or keywords.




## `LubuntuGui::Desktop`

Manages the desktop environment, including wallpaper, themes, and virtual desktops.

### Class Methods

- **`set_wallpaper(image_path)`**: Sets the desktop wallpaper.
- **`get_wallpaper`**: Returns the path to the current wallpaper.
- **`create_desktop_icon(name, command, icon_path)`**: Creates a desktop icon.
- **`remove_desktop_icon(name)`**: Removes a desktop icon.
- **`list_desktop_icons`**: Lists all icons on the desktop.
- **`switch_to(desktop_number)`**: Switches to a specific virtual desktop.
- **`create_desktop`**: Creates a new virtual desktop (not fully supported by LXQt).
- **`remove_desktop(desktop_number)`**: Removes a virtual desktop (not fully supported by LXQt).
- **`desktop_count`**: Returns the number of virtual desktops.
- **`current_desktop`**: Returns the current virtual desktop number.
- **`set_theme(theme_name)`**: Sets the desktop theme.
- **`current_theme`**: Returns the name of the current theme.
- **`set_icon_theme(theme_name)`**: Sets the icon theme.
- **`current_icon_theme`**: Returns the name of the current icon theme.
- **`list_themes`**: Lists all available desktop themes.
- **`list_icon_themes`**: Lists all available icon themes.
- **`screen_resolution`**: Returns the current screen resolution.
- **`set_screen_resolution(width, height)`**: Sets the screen resolution.
- **`lock_screen`**: Locks the screen.
- **`show_desktop`**: Minimizes all windows to show the desktop.
- **`hide_desktop`**: Restores all windows from a minimized state.




## `LubuntuGui::System`

Manages system-level integration, including audio, notifications, network, and power management.

### Class Methods

- **`set_volume(level)`**: Sets the system volume.
- **`get_volume`**: Returns the current volume level.
- **`mute`**: Mutes the system audio.
- **`unmute`**: Unmutes the system audio.
- **`muted?`**: Checks if the audio is muted.
- **`send_notification(title, message, icon, timeout)`**: Sends a desktop notification.
- **`clear_notifications`**: Clears all notifications.
- **`network_status`**: Returns the current network status.
- **`list_networks`**: Lists all available Wi-Fi networks.
- **`battery_status`**: Returns the battery status for laptops.
- **`system_info`**: Returns general system information (OS, kernel, uptime, memory).
- **`cpu_usage`**: Returns the current CPU usage percentage.
- **`disk_usage(path)`**: Returns disk usage information for a given path.
- **`shutdown(delay)`**: Shuts down the system.
- **`restart(delay)`**: Restarts the system.
- **`logout`**: Logs out the current user.




## `LubuntuGui::Configuration`

Manages configuration settings for the gem and the Lubuntu environment.

### Instance Attributes

- **`debug`**: Enables or disables debug mode.
- **`timeout`**: Sets the timeout for shell commands.
- **`lxqt_config_path`**: Path to the LXQt configuration directory.
- **`openbox_config_path`**: Path to the Openbox configuration directory.

### Instance Methods

- **`lxqt_config_file(file)`**: Returns the full path to an LXQt configuration file.
- **`openbox_config_file(file)`**: Returns the full path to an Openbox configuration file.
- **`read_lxqt_config(file)`**: Reads an LXQt configuration file.
- **`write_lxqt_config(file, data)`**: Writes to an LXQt configuration file.
- **`read_openbox_config(file)`**: Reads an Openbox configuration file (XML).
- **`write_openbox_config(file, doc)`**: Writes to an Openbox configuration file (XML).
- **`desktop_entry_dirs`**: Returns a list of directories containing `.desktop` files.
- **`icon_theme_dirs`**: Returns a list of directories containing icon themes.
- **`current_theme`**: Returns the name of the current desktop theme.
- **`set_theme(theme_name)`**: Sets the desktop theme.
- **`current_icon_theme`**: Returns the name of the current icon theme.
- **`set_icon_theme(theme_name)`**: Sets the icon theme.
- **`backup_config(backup_dir)`**: Backs up the current configuration.
- **`restore_config(backup_dir)`**: Restores a previously backed-up configuration.


