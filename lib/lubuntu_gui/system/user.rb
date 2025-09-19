#!/usr/bin/env ruby

require 'fileutils'
require 'erb'

module LubuntuGui

  class User < ItemBase

    attr_accessor :username, :password, :home_directory, :shell_path

    def initialize(source_file:)
      super
      binding.irb
      @u = UserUtility.new(username:'testuser', password:'1234', home_directory:'/home/testuser', shell_path:'/usr/bin/zsh')
      @u.prepare_linux
      @u.prepare_dirs
      @u.prepare_vscode
      @u.prepare_firefox
      @u.prepare_shell_files
    end

  end
end