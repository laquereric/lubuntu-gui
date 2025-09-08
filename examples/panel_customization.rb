# frozen_string_literal: true

require "lubuntu_gui"

puts "LubuntuGui Gem - Panel Customization Demo"
puts "========================================"

# Get current panel configuration
puts "--- Current Panel Configuration ---"
current_config = LubuntuGui::Panel.current_configuration
puts "Position: #{current_config[:position]}"
puts "Size: #{current_config[:size]}px"
puts "Auto-hide: #{current_config[:auto_hide]}"

# Customize the panel
puts "\n--- Customizing Panel ---"
puts "Moving panel to the top and making it larger..."
LubuntuGui::Panel.configure do |config|
  config.position = :top
  config.size = 48
end
sleep(2)

# Add and remove widgets
puts "\n--- Managing Widgets ---"
puts "Adding a new clock widget..."
LubuntuGui::Panel.add_widget(:clock, format: "%H:%M:%S")
sleep(2)

puts "Removing the new clock widget..."
LubuntuGui::Panel.remove_widget(:clock)
sleep(2)

# Manage quick launch
puts "\n--- Managing Quick Launch ---"
puts "Adding Firefox to quick launch..."
LubuntuGui::Panel.add_to_quicklaunch("firefox")
sleep(2)

puts "Removing Firefox from quick launch..."
LubuntuGui::Panel.remove_from_quicklaunch("firefox")
sleep(2)

# Restore original configuration
puts "\n--- Restoring Original Configuration ---"
LubuntuGui::Panel.configure do |config|
  config.position = current_config[:position].to_sym
  config.size = current_config[:size]
  config.auto_hide = current_config[:auto_hide]
end

puts "\nDemo finished."


