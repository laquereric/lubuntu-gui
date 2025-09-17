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
    attr_accessor :directory, :source_file, :catalog, :catalog_path
    
    class CollectorEntry
      attr_accessor :collector
      
      def initialize( collector:)

        puts("CollectorEntry.initialize: collector: #{collector}") if DEBUG
        @collector = collector
      end

      def item
        self.collector
      end
      
      def item_class
        item.class
      end

      def item_class_name
        item_class.name
      end

    end

    class FileEntries
      attr_accessor :collector
      
      def initialize( collector:)
        puts("File.initialize: collector: #{collector}") if DEBUG
        @collector = collector
      end

      def catalog
        collector.catalog
      end

      def get_source_file(file)
        [collector.source_file,file].join('/')
      end

      def instance(catalog_path:, file:)
        
        file_split = file.split('.')
        base = file_split[0]
        ext = file_split[1]

        base_klassname = self.class.name.split('::')[0..-3]
        p file_klassname = [base_klassname, ext.capitalize].join('::')
        begin
          klass = file_klassname.constantize
        rescue
          raise "No class found for directory #{file}. Tried #{directory_klassname}"
        end
        #TODO fix kluge
        klass.new(catalog: catalog, catalog_path: [catalog_path,file].join('/'), source_file: get_source_file(file))
      end

    end
    
    class DirectoryEntries
      attr_accessor :collector

      def initialize(collector:)
        puts("DirectoryEntries.initialize: collector: #{collector}") if DEBUG
        @collector = collector
      end

      def catalog
        collector.catalog
      end

      def get_source_file(directory)
        [collector.source_file, directory].join('/')
      end
      
      def instance(catalog_path:, directory:)
        base_klassname = self.class.name.split('::')[0..-3]
        p directory_klassname = [base_klassname,directory.camelize].join('::')
        begin
          klass = directory_klassname.constantize
        rescue
          raise "No class found for directory #{directory}. Tried #{directory_klassname}"
        end
      
        klass.new(catalog: catalog, catalog_path: [catalog_path, directory].join('/'), source_file: get_source_file(directory))
      end
    end

    # Initialize the collector and load all child components
    def initialize(catalog:, catalog_path:, source_file:)
      @catalog = catalog
      @source_file = source_file
      puts("catalog: #{@catalog} source_file: #{@source_file} name: #{name}") if DEBUG

      collector_category = @catalog.add_category(catalog: catalog_path, category: 'collector')
      @catalog.add_to_category(
        category: collector_category,
        item: CollectorEntry.new(collector: self).collector
      )
      
      if (files = glob_children_folder_files).any?
        #raise "not ready"
        files_category = @catalog.add_category(catalog: collector_category, category: 'file_entries')
        file_entries = FileEntries.new(collector: self)
        files.each{ |file|
          item = file_entries.instance(catalog_path: files_category, file: file)
          @catalog.add_to_category(category: files_category, item: item )
        }
      
      end
  
      if (dirs = glob_children_folder_dirs).any?
        dirs_category = @catalog.add_category(catalog: collector_category, category: 'directory_entries')
        directory_entries = DirectoryEntries.new(collector: self)
        dirs.each{ |directory|
          item = directory_entries.instance(catalog_path: dirs_category, directory: directory)
          @catalog.add_to_category(category: dirs_category, item: item )
        }
      end
    end

    # Overrideable - See Instance for an example
    def catalog_property
      self.class.to_s.split('::').last.downcase
    end

    def directory
      File.expand_path('..',@source_file)
    end 
    #
    # @return [Array<String>] Array of file paths
    def glob_children_folder_files
      puts("glob_children_files: #{glob_string}") if DEBUG
      Dir.glob(glob_string)
        .select { |entry| !ignore_entry(entry) && File.file?(entry) }
        .map { |entry| relative_path(entry) }
    end

    def glob_children_folder_dirs
      puts("glob_children_dirs: #{glob_string}") if DEBUG
      Dir.glob(glob_string)
        .select { |entry| !ignore_entry(entry) && File.directory?(entry) }
        .map { |entry| relative_path(entry) }
    end

    def name
      @source_file.split(".").first
    end

    def children_name
      name
    end
    
    private
    
    def children_directory
      result = File.join(directory,children_name)
      result
    end
    # Get the name for the children directory based on the class name
    #
    # @return [String] The directory name for child components
    def children_name
      result = self.class.name.split("::").last.downcase
      result
    end

    # Get the glob pattern for finding child files
    #
    # @return [String] The glob pattern for Ruby files
    def glob_string
      result = "#{children_directory}/*"
      result
    end

    def directory_path_length
      directory.split('/').length
    end
    
    def entry_path_split(entry)
      entry.split('/')
    end

    def relative_path(entry)
      entry_path_split(entry)[directory_path_length+1..-1].join('/')
    end
    
    def ignore_entry(entry)
      entry.start_with?('.')
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
=begin
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
=end
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
