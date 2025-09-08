# LubuntuGui

A comprehensive Ruby gem for managing Lubuntu desktop GUI applications and components. This gem provides a clean, object-oriented interface for interacting with the LXQt desktop environment and Openbox window manager used in Lubuntu.

## Features

- **Window Management**: Control windows (move, resize, minimize, maximize, close)
- **Panel Management**: Configure LXQt panel, widgets, and quick launch
- **Application Management**: Launch applications and manage desktop icons
- **Desktop Management**: Virtual desktop switching, wallpaper control
- **System Integration**: Volume control, notifications, network management

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lubuntu-gui'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install lubuntu-gui

## Requirements

- Ruby 3.2.3 or higher
- Lubuntu with LXQt desktop environment
- Openbox window manager

## Quick Start

```ruby
require 'lubuntu_gui'

# Check if running on Lubuntu
puts "Running on Lubuntu: #{LubuntuGui.lubuntu?}"

# List all open windows
windows = LubuntuGui::WindowManager.list_windows
puts "Open windows: #{windows.count}"

# Launch an application
LubuntuGui::Application.launch("firefox")

# Set desktop wallpaper
LubuntuGui::Desktop.set_wallpaper("/path/to/your/wallpaper.jpg")

# Send a notification
LubuntuGui::System.send_notification("Hello", "Welcome to LubuntuGui!")

# Control volume
LubuntuGui::System.set_volume(75)
```

## Usage

### Window Management

```ruby
# List all windows
windows = LubuntuGui::WindowManager.list_windows

# Focus a specific window
LubuntuGui::WindowManager.focus_window(window_id)

# Move and resize windows
LubuntuGui::WindowManager.move_window(window_id, 100, 100)
LubuntuGui::WindowManager.resize_window(window_id, 800, 600)

# Minimize/maximize windows
LubuntuGui::WindowManager.minimize_window(window_id)
LubuntuGui::WindowManager.maximize_window(window_id)

# Virtual desktop management
LubuntuGui::WindowManager.switch_desktop(2)
LubuntuGui::WindowManager.move_window_to_desktop(window_id, 3)
```

### Panel Management

```ruby
# Configure panel
LubuntuGui::Panel.configure do |config|
  config.position = :bottom
  config.size = 32
  config.auto_hide = false
end

# Manage widgets
LubuntuGui::Panel.add_widget(:clock, position: :right)
LubuntuGui::Panel.remove_widget(:widget_id)

# Quick launch management
LubuntuGui::Panel.add_to_quicklaunch("firefox")
LubuntuGui::Panel.remove_from_quicklaunch("firefox")
```

### Application Management

```ruby
# Launch applications
LubuntuGui::Application.launch("firefox")
LubuntuGui::Application.launch_command("gnome-calculator")

# Application information
apps = LubuntuGui::Application.list_installed
running = LubuntuGui::Application.is_running?("firefox")

# Desktop icons
LubuntuGui::Application.create_desktop_icon("MyApp", "/usr/bin/myapp", "/usr/share/icons/myapp.png")
```

### Desktop Management

```ruby
# Wallpaper control
LubuntuGui::Desktop.set_wallpaper("/path/to/image.jpg")
current_wallpaper = LubuntuGui::Desktop.get_wallpaper

# Virtual desktops
LubuntuGui::Desktop.switch_to(2)
LubuntuGui::Desktop.create_desktop
LubuntuGui::Desktop.remove_desktop(4)
```

### System Integration

```ruby
# Volume control
LubuntuGui::System.set_volume(50)
volume = LubuntuGui::System.get_volume
LubuntuGui::System.mute
LubuntuGui::System.unmute

# Notifications
LubuntuGui::System.send_notification("Title", "Message", icon: "/path/to/icon.png")
LubuntuGui::System.clear_notifications

# Network information
status = LubuntuGui::System.network_status
networks = LubuntuGui::System.list_networks
```

## Configuration

```ruby
LubuntuGui.configure do |config|
  config.debug = true
  config.timeout = 30
  config.lxqt_config_path = "/home/user/.config/lxqt"
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Testing

Run the test suite:

```bash
# Run all tests
rake test

# Run only RSpec tests
rake spec

# Run only Cucumber tests
rake cucumber

# Run quality checks
rake quality

# Run everything
rake check
```

## Documentation

- **[User Guide](docs/user_guide.md)**: Practical examples and tutorials.
- **[API Reference](docs/api_reference.md)**: Detailed API documentation.

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Testing

This gem uses RSpec for unit testing and Cucumber for behavior-driven development.

- **Run all tests**: `rake test`
- **Run RSpec tests**: `rake spec`
- **Run Cucumber tests**: `rake cucumber`
- **Run quality checks**: `rake quality`

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to contribute.

## License

The gem is available as open source under the terms of the [MIT License](LICENSE).


# lubuntu-gui
