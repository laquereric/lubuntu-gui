ZshellWrapperUser.new do |user|
    user.username = "testuser"
    user.password = "1234"
    user.home_directory = "/home/#{user.username}"
    user.shell_path = "/usr/bin/zsh"
end
