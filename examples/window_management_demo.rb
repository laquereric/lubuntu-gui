# frozen_string_literal: true

require "lubuntu_gui"

puts "LubuntuGui Gem - Window Management Demo"
puts "======================================"

# Launch a few applications to work with
puts "Launching applications..."
LubuntuGui::Application.launch("leafpad")
LubuntuGui::Application.launch("qterminal")
LubuntuGui::Application.launch("pcmanfm-qt")
sleep(3) # Wait for windows to appear

# Get all windows
windows = LubuntuGui::WindowManager.list_windows
puts "Found #{windows.count} windows."

# Tile the windows
puts "Tiling windows..."

screen_res = LubuntuGui::Desktop.screen_resolution
win_width = screen_res[:width] / 2
win_height = screen_res[:height] / 2

positions = [
  { x: 0, y: 0 },
  { x: win_width, y: 0 },
  { x: 0, y: win_height },
  { x: win_width, y: win_height }
]

windows.first(4).each_with_index do |win, i|
  puts "  - Tiling: #{win[:title]}"
  LubuntuGui::WindowManager.focus_window(win[:id])
  LubuntuGui::WindowManager.move_window(win[:id], positions[i][:x], positions[i][:y])
  LubuntuGui::WindowManager.resize_window(win[:id], win_width, win_height)
  sleep(0.5)
end

# Minimize and maximize a window
puts "\nMinimizing and maximizing the first window..."
first_window = windows.first
if first_window
  LubuntuGui::WindowManager.minimize_window(first_window[:id])
  sleep(2)
  LubuntuGui::WindowManager.maximize_window(first_window[:id])
  sleep(2)
end

# Virtual desktop management
puts "\nManaging virtual desktops..."
puts "Current desktop: #{LubuntuGui::Desktop.current_desktop}"

# Move a window to another desktop
if windows.length > 1
  second_window = windows[1]
  puts "Moving window '#{second_window[:title]}' to desktop 1"
  LubuntuGui::WindowManager.move_window_to_desktop(second_window[:id], 1)
end

puts "Switching to desktop 1..."
LubuntuGui::Desktop.switch_to(1)
sleep(2)
puts "Switching back to desktop 0..."
LubuntuGui::Desktop.switch_to(0)

# Close all launched applications
puts "\nClosing launched applications..."
windows.each do |win|
  if ["leafpad", "qterminal", "pcmanfm-qt"].any? { |app| win[:class].include?(app) }
    puts "  - Closing: #{win[:title]}"
    LubuntuGui::WindowManager.close_window(win[:id])
  end
end

puts "\nDemo finished."


