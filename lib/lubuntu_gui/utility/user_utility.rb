require 'fileutils'
require 'erb'

module LubuntuGui
# users.rb - User management utilities
#ZshellWrapper::User.new do |user|
  class UserUtility < BaseUtility
    attr_accessor :username, :password

    def initialize(username:, password:)
      @username = username
      @password = password
      @home_directory = "/home/#{@username}"
      @shell_path = "/usr/bin/zsh"
    end
    
    def prepare_linux
      `useradd -m #{@username}`
      `usermod -s #{@shell_path} #{@username}`
      `echo "#{@username}:#{@password}" | chpasswd`
      `usermod -aG sudo #{@username}`
      `chown -R #{@username}:#{@username} #{@home_directory}`

      @display = `detect_display`
    end

    def prepare_dirs
      create_user_dir(relative_path: '.config')
      create_user_dir(relative_path: '.config/autostart')
      create_user_dir(relative_path: 'Desktop')
      create_user_dir(relative_path: 'Documents')
      create_user_dir(relative_path: 'Downloads')
      create_user_dir(relative_path: 'vscode-workspace')
    end

##############

    def prepare_firefox
      create_user_dir(relative_path: 'firefox-state')
      create_user_file_from_template(template_name: 'firefox.desktop', relative_path: '.config/autostart/firefox.desktop')
      create_user_file_from_template(template_name: 'start-firefox.erb', relative_path: 'start-firefox.sh')
      @firefox_profile_includes = create_content_from_template(template_name: 'firefox_profile_includes.erb', relative_path: '.profile.includes')
      @firefox_bashrc_includes = create_content_from_template(template_name: 'firefox_bashrc_includes.erb', relative_path: '.bashrc.includes')
    end

#############

    def prepare_vscode
      create_userdir(relative_path: 'vscode-workspace')
      @vscode_bashrc_includes = create_content_from_template(template_name: 'vscode_bashrc_includes.erb', relative_path: '.bashrc.includes')
    end

############

    def prepare_shell_files
      bashrc_includes = %w[@firefox_bashrc_includes @vscode_bashrc_includes].join("\n")
      create_user_file_from_template(template_name: 'bashrc.erb', binding: binding, relative_path: '.bashrc')

      profile_includes = %w[@firefox_profile_includes @vscode_profile_includes].join("\n")
      create_user_file_from_template(template_name: 'profile.erb', binding: binding, relative_path: '.profile')
    end
##############

    def create_dir(relative_path:)
      directory_path = File.join(@home_directory, relative_path)
      `mkdir -p #{directory_path}`
      `chmod 755 #{directory_path}`
      `chown #{@username}:#{@username} #{directory_path} 2>/dev/null`
    end

    def create_content_from_template(template_name:, binding:)
      template_erb_template = File.read("#{template_name}.erb")
      template_erb = ERB.new(template_erb_template, trim_mode: "%<>")
      template_erb.result(binding)
    end

    def create_file_from_template(template_name:, binding:, relative_path:)
      template_content = create_content_from_template(template_name:, binding:)
      File.write("#{@home_directory}/#{relative_path}", template_content)
      `chown -R #{@username}:#{@username} #{@home_directory}/#{relative_path}`
      `chmod +x #{@home_directory}/#{relative_path}`
    end

    private
    
    def create_desktop_entry(type:, name:, comment:, exec:)
      create_file_from_template(template_name: 'desktop_entry.erb', binding: binding, relative_path: '.config/autostart/firefox.desktop')
    end

    def create_user_dir(relative_path:)
      directory_path = File.join(@home_directory, relative_path)
      `mkdir -p #{directory_path}`
      `chmod 755 #{directory_path}`
      `chown #{@username}:#{@username} #{directory_path} 2>/dev/null`
    end

    def create_file_from_template(template_name:, binding:, relative_path:)
      template_content = create_content_from_template(template_name:, binding:)
      File.write("#{@home_directory}/#{relative_path}", template_content)
      `chown -R #{@username}:#{@username} #{@home_directory}/#{relative_path}`
      `chmod +x #{@home_directory}/#{relative_path}`
    end
  end
end


 