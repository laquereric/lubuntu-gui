require 'fileutils'
require 'erb'

module LubuntuGui
# users.rb - User management utilities
#ZshellWrapper::User.new do |user|
  class SystemUtility < BaseUtility
    def create_for_system
      puts "Creating system-wide autostart entries..."
      create_dir(absolute_path: "/etc/xdg/autostart")
    end
  end
end


 