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
  class Folder < CollectorBase
    attr_accessor :directory

    # Initialize a new directory instance
    #
    # @param directory [String] The directory path to manage
    # @param source_file [String] The source file path
    # @param catalog [Catalog] The catalog instance
    # @param catalog_path [String] The catalog path
    # Calls the parent constructor to set up the children collection
    def initialize(directory:, source_file:, catalog:, catalog_path:)
      super(directory: directory, source_file: source_file, catalog: catalog, catalog_path: catalog_path)
    end
  end
end
