# frozen_string_literal: true

module LubuntuGui
  # Dir class for managing directory contents and their components
  #
  # This class provides functionality to manage directory contents and
  # their associated components. It inherits from CollectorBase to
  # automatically discover and load child components from the directory
  # structure.
  #
  # @example Basic usage
  #   dir = LubuntuGui::Dir.new(directory: "/path/to/directory")
  #   puts dir.children
  #
  # @author Lubuntu GUI Team
  # @since 1.0.0
  class Dir < CollectorBase
    attr_accessor :directory

    # Initialize a new directory instance
    #
    # @param directory [String] The directory path to manage
    # Calls the parent constructor to set up the children collection
    def initialize(directory:)
      super(directory: directory)
    end
  end
end
