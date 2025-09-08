# User Guide

Welcome to the LubuntuGui user guide! This document provides practical examples and tutorials to help you get started with the gem.

## Installation

First, make sure you have Ruby 3.2.3 or higher installed. Then, install the gem:

```bash
gem install lubuntu-gui
```

Or, if you're using Bundler, add this to your `Gemfile`:

```ruby
gem 'lubuntu-gui'
```

And run `bundle install`.

## Basic Concepts

The gem is organized into several modules, each responsible for a specific part of the desktop environment:

- **`LubuntuGui::WindowManager`**: Controls windows.
- **`LubuntuGui::Panel`**: Manages the LXQt panel.
- **`LubuntuGui::Application`**: Handles application launching and management.
- **`LubuntuGui::Desktop`**: Manages the desktop itself (wallpaper, themes, etc.).
- **`LubuntuGui::System`**: Interacts with system services (audio, network, etc.).
- **`LubuntuGui::Configuration`**: Manages configuration files.

## Getting Started

Here's a simple example of how to use the gem:

```ruby
require 'lubuntu_gui'

# Check if you're running on Lubuntu
if LubuntuGui.lubuntu?
  puts "Welcome to Lubuntu!"
else
  puts "This gem is designed for Lubuntu."
  exit
end

# Get a list of all open windows
windows = LubuntuGui::WindowManager.list_windows
puts "You have #{windows.count} windows open."

# Launch a new application
puts "Launching the file manager..."
LubuntuGui::Application.launch('pcmanfm-qt')

# Send a notification
LubuntuGui::System.send_notification('Hello!', 'This is a test notification from LubuntuGui.')
```




## Window Management Examples

### Listing and Focusing Windows

```ruby
# Get all open windows
windows = LubuntuGui::WindowManager.list_windows

# Find a specific window by title
firefox_windows = LubuntuGui::WindowManager.find_windows_by_title("Mozilla Firefox")

if firefox_windows.any?
  # Focus the first Firefox window found
  LubuntuGui::WindowManager.focus_window(firefox_windows.first[:id])
end
```

### Moving and Resizing Windows

```ruby
# Get the active window
active_window_id = LubuntuGui::WindowManager.list_windows.find { |w| w[:active] }&.[](:id)

if active_window_id
  # Move the window to the top-left corner
  LubuntuGui::WindowManager.move_window(active_window_id, 0, 0)

  # Resize the window to 800x600
  LubuntuGui::WindowManager.resize_window(active_window_id, 800, 600)
end
```

### Managing Virtual Desktops

```ruby
# Get the number of desktops
num_desktops = LubuntuGui::Desktop.desktop_count
puts "You have #{num_desktops} virtual desktops."

# Switch to the second desktop
LubuntuGui::Desktop.switch_to(1) # Desktops are 0-indexed

# Move the active window to the third desktop
active_window_id = LubuntuGui::WindowManager.list_windows.find { |w| w[:active] }&.[](:id)
LubuntuGui::WindowManager.move_window_to_desktop(active_window_id, 2) if active_window_id
```




## Panel Management Examples

### Customizing the Panel

```ruby
# Change the panel position and size
LubuntuGui::Panel.configure do |config|
  config.position = :top
  config.size = 48
  config.auto_hide = true
end

puts "Panel has been reconfigured!"
```

### Managing Quick Launch

```ruby
# Add an application to the quick launch bar
LubuntuGui::Panel.add_to_quicklaunch("firefox")

# Remove an application from the quick launch bar
LubuntuGui::Panel.remove_from_quicklaunch("leafpad")

# Get the list of quick launch apps
quick_launch_apps = LubuntuGui::Panel.quicklaunch_applications
puts "Quick launch apps: #{quick_launch_apps.join(', ')}"
```




## Application Management Examples

### Launching and Finding Applications

```ruby
# Launch an application
LubuntuGui::Application.launch("qterminal")

# Check if an application is running
if LubuntuGui::Application.is_running?("qterminal")
  puts "QTerminal is running."
end

# Find an application by name
app_info = LubuntuGui::Application.find_by_name("Firefox")
if app_info
  puts "Found Firefox: #{app_info[:description]}"
end
```

### Managing Desktop Icons

```ruby
# Create a new desktop icon
LubuntuGui::Desktop.create_desktop_icon(
  "My App",
  "/usr/bin/my_app",
  "/usr/share/icons/my_app.png"
)

# Remove a desktop icon
LubuntuGui::Desktop.remove_desktop_icon("My App")
```




## Desktop Management Examples

### Changing Wallpaper and Themes

```ruby
# Set a new wallpaper
LubuntuGui::Desktop.set_wallpaper("/path/to/your/image.jpg")

# Get the current wallpaper
current_wallpaper = LubuntuGui::Desktop.get_wallpaper
puts "Current wallpaper: #{current_wallpaper}"

# Change the desktop theme
LubuntuGui::Desktop.set_theme("Adwaita-dark")

# Change the icon theme
LubuntuGui::Desktop.set_icon_theme("breeze-dark")
```

### Screen Management

```ruby
# Get the screen resolution
resolution = LubuntuGui::Desktop.screen_resolution
puts "Screen resolution: #{resolution[:width]}x#{resolution[:height]}"

# Lock the screen
LubuntuGui::Desktop.lock_screen
```




## System Integration Examples

### Controlling Volume and Notifications

```ruby
# Set the volume to 75%
LubuntuGui::System.set_volume(75)

# Mute the audio
LubuntuGui::System.mute

# Send a notification
LubuntuGui::System.send_notification(
  "System Alert",
  "This is an important message!",
  icon: "dialog-warning"
)
```

### Getting System Information

```ruby
# Get system info
system_info = LubuntuGui::System.system_info
puts "OS: #{system_info[:os]}"
puts "Kernel: #{system_info[:kernel]}"

# Get CPU and memory usage
cpu_usage = LubuntuGui::System.cpu_usage
mem_usage = LubuntuGui::System.system_info[:memory][:percentage]
puts "CPU: #{cpu_usage}% | Memory: #{mem_usage}%"

# Get battery status
battery = LubuntuGui::System.battery_status
if battery[:available]
  puts "Battery: #{battery[:percentage]}% (#{battery[:charging] ? 'charging' : 'discharging'})
end
```

### Power Management

```ruby
# Logout the current user
# LubuntuGui::System.logout

# Restart the system
# LubuntuGui::System.restart

# Shutdown the system with a 1-minute delay
# LubuntuGui::System.shutdown(delay: 1)
```


