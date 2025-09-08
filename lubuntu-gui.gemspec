# frozen_string_literal: true

require_relative "lib/lubuntu_gui/version"

Gem::Specification.new do |spec|
  spec.name = "lubuntu-gui"
  spec.version = LubuntuGui::VERSION
  spec.authors = ["Lubuntu GUI Team"]
  spec.email = ["info@lubuntu-gui.com"]

  spec.summary = "A Ruby gem for managing Lubuntu desktop GUI applications and components"
  spec.description = <<~DESC
    LubuntuGui provides a comprehensive Ruby interface for managing Lubuntu desktop environment
    components including window management, panel configuration, application launching,
    desktop management, and system integration. Built specifically for the LXQt desktop
    environment and Openbox window manager used in Lubuntu.
  DESC
  spec.homepage = "https://github.com/lubuntu-gui/lubuntu-gui"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.3"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/lubuntu-gui/lubuntu-gui"
  spec.metadata["changelog_uri"] = "https://github.com/lubuntu-gui/lubuntu-gui/blob/main/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://rubydoc.info/gems/lubuntu-gui"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z 2>/dev/null`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "ruby-dbus", "~> 0.25"
  spec.add_dependency "nokogiri", "~> 1.15"
  spec.add_dependency "inifile", "~> 3.0"

  # Development dependencies
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "cucumber", "~> 9.0"
  spec.add_development_dependency "yard", "~> 0.9"
  spec.add_development_dependency "rubocop", "~> 1.50"
  spec.add_development_dependency "rubocop-rspec", "~> 2.20"
  spec.add_development_dependency "simplecov", "~> 0.22"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end

