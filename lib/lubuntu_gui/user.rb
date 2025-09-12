#!/usr/bin/env ruby

require 'fileutils'

# users.rb - User management utilities

class User
  def initialize
    @users = []
  end

  def add_user(username, home_dir = nil)
    home_dir ||= "/home/#{username}"
    @users << { username: username, home_dir: home_dir }
    puts "Added user: #{username} with home directory: #{home_dir}"
  end

  def list_users
    @users.each do |user|
      puts "User: #{user[:username]}, Home: #{user[:home_dir]}"
    end
  end

  def create_user_directories
    @users.each do |user|
      FileUtils.mkdir_p(user[:home_dir]) unless Dir.exist?(user[:home_dir])
      puts "Created directory for #{user[:username]}: #{user[:home_dir]}"
    end
  end
end

if __FILE__ == $0
  users = Users.new
  users.add_user("testuser")
  users.list_users
  users.create_user_directories
end
