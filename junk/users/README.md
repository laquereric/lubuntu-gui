# Ruby Script Implementations

This directory contains Ruby implementations of the bash scripts found in the parent directory. These Ruby scripts provide the same functionality as their bash counterparts but with improved error handling, better structure, and Ruby's object-oriented approach.

## Available Scripts

### Core Scripts

1. **`get_display.rb`** - Detect and return the correct display for X11 applications
   - Usage: `./get_display.rb [--default DISPLAY] [--verbose]`
   - Replaces: `get_display`

2. **`add_a_user.rb`** - Add a user with VS Code auto-launch configuration
   - Usage: `./add_a_user.rb --username USERNAME --password PASSWORD [--port PORT] [--host HOST]`
   - Replaces: `add_a_user`

3. **`config_apps.rb`** - Configure applications (VSCode and Firefox) for a user
   - Usage: `./config_apps.rb --username USERNAME [--port PORT] [--host HOST] [--display DISPLAY]`
   - Replaces: `config_apps`

4. **`add_user_dirs.rb`** - Create user directories for persistent profiles and data
   - Usage: `./add_user_dirs.rb [--user USERNAME | --all]`
   - Replaces: `add_user_dirs`

5. **`setup_desktop_shortcuts.rb`** - Create desktop shortcuts and autostart entries
   - Usage: `./setup_desktop_shortcuts.rb [--user USERNAME | --system]`
   - Replaces: `setup-desktop-shortcuts.sh`

## Key Improvements

### Object-Oriented Design
- Each script is implemented as a Ruby class with clear separation of concerns
- Methods are organized logically (parsing, validation, execution)
- Better code reusability and maintainability

### Error Handling
- Comprehensive error handling with proper exit codes
- Clear error messages and usage instructions
- Graceful handling of system command failures

### Input Validation
- Robust argument parsing using Ruby's `OptionParser`
- Required parameter validation
- Clear usage messages and examples

### Ruby Best Practices
- Proper use of Ruby idioms and conventions
- Clean, readable code structure
- Consistent naming and formatting

## Usage Examples

### Get Display
```bash
# Basic usage
./get_display.rb

# With custom default
./get_display.rb --default :1

# With verbose output
./get_display.rb --verbose
```

### Add User
```bash
# Create a new user
./add_a_user.rb --username testuser --password 1234

# With custom VS Code settings
./add_a_user.rb --username developer --password dev123 --port 9000 --host 127.0.0.1
```

### Configure Apps
```bash
# Configure apps for existing user
./config_apps.rb --username testuser

# With custom settings
./config_apps.rb --username testuser --port 9000 --display :1
```

### Create User Directories
```bash
# Create directories for specific user
./add_user_dirs.rb --user testuser

# Create directories for all default users
./add_user_dirs.rb --all
```

### Setup Desktop Shortcuts
```bash
# Create shortcuts for specific user
./setup_desktop_shortcuts.rb --user testuser

# Create system-wide autostart entries
./setup_desktop_shortcuts.rb --system
```

## Dependencies

These Ruby scripts require:
- Ruby 2.0+ (uses standard library only)
- Standard Ruby gems: `optparse`, `open3`, `fileutils`
- System commands: `useradd`, `chpasswd`, `chown`, `chmod`, etc.

## Migration from Bash

To migrate from bash scripts to Ruby scripts:

1. Replace script calls in your Dockerfile or entrypoint scripts
2. Update any shell scripts that call these utilities
3. Test functionality to ensure equivalent behavior
4. Update documentation and usage examples

## Benefits of Ruby Implementation

1. **Better Error Handling**: More robust error detection and reporting
2. **Cleaner Code**: Object-oriented structure is easier to maintain
3. **Cross-Platform**: Ruby scripts work consistently across different systems
4. **Extensibility**: Easier to add new features and functionality
5. **Testing**: Ruby's testing frameworks make it easier to write unit tests
6. **Documentation**: Better inline documentation and usage examples

## Future Enhancements

Potential improvements for these Ruby scripts:
- Add unit tests using RSpec or Minitest
- Add logging functionality
- Implement configuration file support
- Add dry-run mode for testing
- Create a gem for easy installation and distribution
