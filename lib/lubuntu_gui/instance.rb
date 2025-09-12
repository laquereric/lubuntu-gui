# frozen_string_literal: true

module LubuntuGui
  # Instance class for managing application instances and their components
  #
  # This class provides functionality to manage instances of applications
  # and their associated components. It inherits from CollectorBase to
  # automatically discover and load child components from the instance
  # directory structure.
  #
  # @example Basic usage
  #   instance = LubuntuGui::Instance.new
  #   puts instance.children
  #
  # @author Lubuntu GUI Team
  # @since 1.0.0
  class Instance < CollectorBase
    attr_accessor :directory
    # Initialize a new instance
    #
    # Calls the parent constructor to set up the children collection
    def initialize(directory:)
      super(directory: directory)
    end
  end
end
