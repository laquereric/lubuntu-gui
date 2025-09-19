require 'fileutils'
require 'erb'

module LubuntuGui
# users.rb - User management utilities
#ZshellWrapper::User.new do |user|
  class BaseUtility
 
    def create_content_from_template(template_name:, binding:)
      template_erb_template = File.read("#{template_name}.erb")
      template_erb = ERB.new(template_erb_template, trim_mode: "%<>")
      template_erb.result(binding)
    end

    def create_desktop_entry(type:, name:, comment:, exec:)
      create_file_from_template(template_name: 'desktop_entry.erb', binding: binding, relative_path: '.config/autostart/firefox.desktop')
    end

  end
end