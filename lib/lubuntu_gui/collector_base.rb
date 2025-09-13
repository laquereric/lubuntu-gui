# frozen_string_literal: true

module LubuntuGui
  # Base class for collecting and managing child components dynamically
  #
  # This class provides functionality to automatically discover and load
  # child components from a directory structure. It's designed to work
  # with the Lubuntu GUI gem's modular architecture.
  #
  # @example Basic usage
  #   class MyCollector < LubuntuGui::CollectorBase
  #     # Automatically loads all .rb files from the my_collector/ directory
  #   end
  #
  # @author Lubuntu GUI Team
  # @since 1.0.0
  DEBUG = true

  class CollectorBase
    attr_accessor :children

    def self.item_class
        classname = self.name.split("::").last.singularize.capitalize
        puts("classname: #{classname}") if DEBUG
        [LubuntuGui,classname].join("::").constantize
    end

    # Initialize the collector and load all child components
    def initialize(source_file:)
      @source_file = source_file
      @name = name
      @directory = directory
      puts("directory: #{@directory}") if DEBUG
      @children = get_children
    end

    def basename
        @name.split(".").first
    end
    private

    # Get the name for the children directory based on the class name
    #
    # @return [String] The directory name for child components
    def children_name
      result = self.class.name.split("::").last.downcase
      puts("children_name: #{result}") if DEBUG
      result
    end

    # Get the full path to the children directory
    #
    # @return [String] The full path to the children directory
    def children_folder
      result = File.expand_path("#{@directory}/#{children_name}", __FILE__)
      puts("children_folder: #{result}") if DEBUG
      result
    end

    # Get the glob pattern for finding child files
    #
    # @return [String] The glob pattern for Ruby files
    def glob_string
      result = "#{children_folder}/*"
      result
    end

    # Get all files matching the glob pattern
    #
    # @return [Array<String>] Array of file paths
    def glob_children_folder
      result = ::Dir.glob(glob_string, File::FNM_DOTMATCH).reject { |path| File.basename(path).start_with?('.') }
      puts("glob_children_folder: #{result}") if DEBUG
      result
    end

    # Evaluate a file and return file info and evaluation result
    #
    # @param file [String] Path to the file to evaluate
    # @return [Hash] Hash containing file path and evaluation result
    def eval_file(file)
      klass = self.class.item_class
      puts("klass: #{klass}") if DEBUG
      name = [self.basename,'.',File.basename(file).capitalize].join("")
      puts("name: #{name}") if DEBUG
      directory = File.dirname(file)
      puts("directory: #{directory}") if DEBUG
      {
        file: file,
        # evaled: load(file)
        evaled: klass.new(name: name, source_file: file, directory: directory)
      }
    end

    # Add a file to the accumulator
    #
    # @param acc [Hash] The accumulator hash
    # @param file [String] Path to the file to add
    def add_file(acc, file)
      acc[file] = eval_file(file)[:evaled]
    end

    # Add a directory to the accumulator by instantiating the corresponding class
    #
    # @param acc [Hash] The accumulator hash
    # @param dir [String] Path to the directory to add
    def add_dir(acc, dir)
      # Extract directory name and look up corresponding class
      class_name = File.basename(dir).capitalize
      
      # Check if the class name is valid for Ruby constants
      unless class_name.match?(/\A[A-Z][a-zA-Z0-9_]*\z/)
        puts("Invalid class name '#{class_name}' for directory '#{dir}' - skipping") if DEBUG
        return
      end
      
      # Look up the class in the LubuntuGui module
      if LubuntuGui.const_defined?(class_name)
        collection_klass = LubuntuGui.const_get(class_name)
        puts("collection_klass: #{collection_klass}") if DEBUG
        instance = collection_klass.new(name: [self.basename,'.',class_name.downcase].join(""),source_file: @source_file, directory: File.dirname(dir))
        acc[dir] = instance
      else
        puts("Class LubuntuGui::#{class_name} not found") if DEBUG
      end
    end

    # Get all child components by scanning the children directory
    #
    # @return [Hash] Hash of file paths to their evaluation result or instance of the class
    def get_children
      result = glob_children_folder.each_with_object({}) do |file_or_dir, acc|
        file = file_or_dir if File.file?(file_or_dir)
        dir = file_or_dir if File.directory?(file_or_dir)
        
        if file
          add_file(acc, file)
        elsif dir
          add_dir(acc, dir)
        end
      end
      
      puts("get_children: #{result}") if DEBUG
      result
    end
  end
end
