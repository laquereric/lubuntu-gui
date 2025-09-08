# frozen_string_literal: true

require "lubuntu_gui"

puts "LubuntuGui Gem - Basic Usage Example"
puts "===================================="

# Check if running on Lubuntu
if LubuntuGui.lubuntu?
  puts "Running on a Lubuntu system."
else
  puts "Warning: This gem is designed for Lubuntu. Some features may not work."
end

# --- Window Management ---
puts "\n--- Window Management ---"
windows = LubuntuGui::WindowManager.list_windows
puts "Found #{windows.count} open windows."
windows.first(5).each do |w|
  puts "  - ID: #{w[:id]}, Title: #{w[:title]}"
end

# --- Application Management ---
puts "\n--- Application Management ---"
puts "Launching Leafpad..."
LubuntuGui::Application.launch("leafpad")
sleep(2) # Give it time to open

leafpad_window = LubuntuGui::WindowManager.find_windows_by_title("Untitled - Leafpad").first
if leafpad_window
  puts "Found Leafpad window. Moving and resizing it."
  LubuntuGui::WindowManager.move_window(leafpad_window[:id], 100, 100)
  LubuntuGui::WindowManager.resize_window(leafpad_window[:id], 600, 400)
  sleep(1)
  puts "Closing Leafpad..."
  LubuntuGui::WindowManager.close_window(leafpad_window[:id])
else
  puts "Could not find Leafpad window."
end

# --- Desktop Management ---
puts "\n--- Desktop Management ---"
puts "Current wallpaper: #{LubuntuGui::Desktop.get_wallpaper || 'Not found'}"
puts "Current theme: #{LubuntuGui::Desktop.current_theme}"
puts "Current icon theme: #{LubuntuGui::Desktop.current_icon_theme}"

# --- System Integration ---
puts "\n--- System Integration ---"
puts "Sending a notification..."
LubuntuGui::System.send_notification(
  "LubuntuGui Example",
  "This is a test notification.",
  icon: "info"
)

puts "Current volume: #{LubuntuGui::System.get_volume}%"
LubuntuGui::System.set_volume(80)
puts "Volume set to 80%"

puts "\n--- System Information ---"
sys_info = LubuntuGui::System.system_info
puts "OS: #{sys_info[:os]}"
puts "Kernel: #{sys_info[:kernel]}"
puts "Uptime: #{sys_info[:uptime]}"

battery = LubuntuGui::System.battery_status
if battery[:available]
  puts "Battery: #{battery[:percentage]}%"
end

puts "\nExample finished."


