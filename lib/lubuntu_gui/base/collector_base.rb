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

    class CollectorInstanceObject
      attr_accessor :collector
      
      def initialize( collector:)
        puts("CollectorInstanceObject.initialize: collector: #{collector}") if DEBUG
        @collector = collector
      end

      def item_label
        self.collector.name + '_collector_object'
      end

      def item_hash
        r = {}
        r[item_label] = collector
        r
      end
    end

    class FileEntries
      attr_accessor :collector

      def self.get_file_entries(collector:)
        FileEntries.new(collector: collector)
      end

      def self.process(collector:, catalog_path:, files:)
        file_entries = FileEntries.get_file_entries(collector: collector)
        files.each{ |file|
          item = file_entries.create_instance(catalog_path: catalog_path, file: file)
          collector.catalog.add_to_category(
            catalog_path: file_entries.get_catalog_path(catalog_path:catalog_path, file: file),
            item: item
          )
        }
      end

      def initialize(collector:)
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
        [collector.source_file,file_parse(file)[:last]].join('/')
      end

      def create_instance(catalog_path:, file:)
        file_klassname = [catalog.instance.base_klassname,file_parse(file)[:ext].camelize].join('::')
        puts("file_klassname: #{file_klassname}") if DEBUG
        file_klassname.constantize.new(
          catalog: catalog,
          catalog_path: get_catalog_path(catalog_path: catalog_path, file: file),
          source_file: get_source_file(file)
        ).build
      end

    end
    
    class DirectoryObject
      attr_accessor :collector

      def self.get_directory_object(collector:)
        DirectoryObject.new(collector: collector)
      end

      def self.process(collector:, directories:)
        directory_object = get_directory_object(collector: collector)
        directories.each{ |directory|
          yield item = directory_object.create_instance(directory: directory)
          #collector.catalog.add_to_category(
          #  catalog_path: catalog_path,
          #  item: item
          #)
          #PP.pp collector.catalog.parts
          #binding.irb
          item.collector.build
        }
      end

      def initialize(collector:)
        puts("DirectoryEntries.initialize: collector: #{collector}") if DEBUG
        @collector = collector
      end

      def catalog
        collector.catalog
      end

      def get_catalog_path(directory:)
        # collector_
        [catalog_path, directory_parse(directory)[:last]].join('/')
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

      def create_instance(directory:)
        directory_collector = directory_klassname(directory).constantize.new(
          source_file: get_next_source_file(directory)
        )
        CollectorInstanceObject.new(collector: directory_collector)
      end
    
    end

    # Initialize the collector and load all child components
    def initialize(source_file:)
      @source_file = source_file
      puts("source_file: #{@source_file} name: #{name}") if DEBUG
    end
    
    def build
      raise "cannot build collector #{self.class.name} without catalog" if @catalog.nil?
      raise "cannot build collector #{self.class.name} without catalog_path" if @catalog_path.nil?

      collector_category = create_collector_category(catalog_path: catalog_path)
      @globber = Globber.new(children_directory: @source_file)
      #create_files_category(catalog_path: collector_catalog_path)
      create_directories_category(catalog_path: collector_category)
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

    def create_collector_category(catalog_path:)
      collector_object = CollectorInstanceObject.new(collector: self)
      category_label ='collector'+"_"+'instance'
      category_catalog_path = @catalog.add_category(catalog_path: catalog_path, category: category_label)
      @catalog.add_to_category(
        category_catalog_path: category_catalog_path,
        item_hash: collector_object.item_hash
      )
    end

    def create_directories_category(catalog_path:)
      directories = @globber.glob_children_folder_dirs
      return unless directories.any?
      category_label ='directories'+"_"+'instance'
      category_catalog_path = @catalog.add_category(catalog_path: catalog_path, category: category_label)
      DirectoryObject.process(collector: self, directories: directories) do |item|
        item.collector.catalog = @catalog
        item.collector.catalog_path = catalog_path + '/' + item.collector.name
        @catalog.add_to_category(
          category_catalog_path: category_catalog_path,
          item_hash: item.item_hash
        )
      end
    end

    def create_files_category
      files = @globber.glob_children_folder_files
      return unless files.any?
      FileEntries.process(
        collector: self,
        catalog_path: @catalog.add_category(catalog_path: @collector_catalog_path, category: 'files'),
        files: files 
      )
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
