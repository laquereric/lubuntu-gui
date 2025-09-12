ZshellWrapperUser.new do |user|
    user.username = "coder"
    user.password = "coder123"
    user.home_directory = "/home/#{user.username}"
    user.shell_path = "/usr/bin/zsh"
end
