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
    
    class Globber
      def self.ignore_entry(entry)
        entry.start_with?('.')
      end
      
      def initialize(children_directory:)
        @children_directory = children_directory
        @glob_string = "#{children_directory}/*"
      end
  
      # @return [Array<String>] Array of file paths
      def glob_children_folder_files
        puts("glob_children_files: #{@glob_string}") if DEBUG
        Dir.glob(@glob_string)
          .select { |entry| 
            result = !Globber.ignore_entry(entry) && File.file?(entry)
            p "files entry: #{entry} result: #{result}"
            result
          }
      end
  
      def glob_children_folder_dirs
        puts("glob_children_dirs: #{@glob_string}") if DEBUG
        Dir.glob(@glob_string)
          .select { |entry| 
            result = !Globber.ignore_entry(entry) && File.directory?(entry)
            p "dirs entry: #{entry} result: #{result}"
            result
          }
      end

      private

    end

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

      def self.process(collector:, category:, files:)
        file_entries = FileEntries.new(collector: collector)
        files.each{ |file|
          item = file_entries.instance(catalog_path: category, file: file)
          category.add_to_category(category: category, item: item )
        }
      end

      def initialize( collector:)
        puts("File.initialize: collector: #{collector}") if DEBUG
        @collector = collector
      end
    
      def file_parse(file)
        file_split = file.split('.')
        base = file_split[0]
        path = base.split('/')
        {
          base: base,
          ext: file_split[1],
          path: path,
          last: path[-1]
        }
      end

      def catalog
        collector.catalog
      end

      def get_catalog_path(catalog_path:, file:)
        [collector.catalog_path,file].join('/')
      end
      
      def get_source_file(file)
        [collector.source_file,file].join('/')
      end

      def instance(catalog_path:, file:)

        file_klassname = [catalog.instance.base_klassname,file_parse(file)[:ext].camelize].join('::')
        puts("file_klassname: #{file_klassname}") if DEBUG
        file_klassname.constantize.new(
          catalog: catalog,
          catalog_path: get_catalog_path(catalog_path: catalog_path, file: file),
          source_file: get_source_file(file)
        ).build
      end

    end
    
    class DirectoryEntries
      attr_accessor :collector
      
      def self.process(collector:, category:, directories:)
        directory_entries = DirectoryEntries.new(collector: collector)
        directories.each{ |directory|
          item = directory_entries.instance(catalog_path: category, directory: directory)
          collector.catalog.add_to_category(category: category, item: item )
        }
      end

      def initialize(collector:)
        puts("DirectoryEntries.initialize: collector: #{collector}") if DEBUG
        @collector = collector
      end

      def catalog
        collector.catalog
      end

      def get_catalog_path(catalog_path:, directory:)
        [collector.catalog_path, directory_parse(directory)[:last]].join('/')
      end

      def get_next_source_file(directory)
        [collector.source_file, directory_parse(directory)[:last]].join('/')
      end
      
      def directory_parse(directory)
        file_split = directory.split('.')
        base = file_split[0]
        path = base.split('/')
        {
          base: base,
          ext: file_split[1],
          path: path,
          last: path[-1]
        }
      end

      def directory_klassname(directory)
        directory_klassname = [catalog.instance.base_klassname, catalog.instance.last_klassname(source_file: directory)].join('::')
      end

      def instance(catalog_path:, directory:)
        directory_klassname(directory).constantize.new(
          catalog: catalog,
          catalog_path: get_catalog_path(catalog_path: catalog_path, directory: directory),
          source_file: get_next_source_file(directory)
        ).build
      end
    end

    # Initialize the collector and load all child components
    def initialize(catalog:, catalog_path:, source_file:)
      @catalog = catalog
      @source_file = source_file
      puts("catalog: #{@catalog} source_file: #{@source_file} name: #{name}") if DEBUG
    end
    
    def build
      create_collector_catagory(catalog_path: catalog_path)
      @globber = Globber.new(children_directory: @source_file)
      create_files_catagory
      create_dirs_catagory
      self
    end
    
    def name
      @source_file.split(".").first
    end

    def children_name
      name
    end

    # Overrideable - See Instance for an example
    def catalog_property
      self.class.to_s.split('::').last.downcase
    end

    def directory
      File.expand_path('..',@source_file)
    end
    
    def last_klassname(source_file:)
      source_file.split('/')[-1].camelize
    end

    def base_klassname
      self.class.name.split('::')[0..-2]
    end

    private

    def create_collector_catagory(catalog_path:)
      @collector_category = @catalog.add_category(catalog: catalog_path, category: 'collector')
      @catalog.add_to_category(
        category: @collector_category,
        item: CollectorEntry.new(collector: self).collector
      )
    end

    def create_files_catagory
      files = @globber.glob_children_folder_files
      return unless files.any?
      @files_category = @catalog.add_category(catalog: @collector_category, category: 'files')
      FileEntries.process(collector: self, category: @files_category, files: files )
    end
    
    def create_dirs_catagory
      directories = @globber.glob_children_folder_dirs
      return unless directories.any?
      @directory_category = @catalog.add_category(catalog: @collector_category, category: 'directories')
      DirectoryEntries.process(collector: self, category: @directory_category, directories: directories )
    end

=begin 
    def directory_path_length
      directory.split('/').length
    end
    
    def entry_path_split(entry)
      entry.split('/')
    endy
=end

  end
end
