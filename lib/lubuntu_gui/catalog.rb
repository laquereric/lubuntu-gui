module LubuntuGui
    class Catalog
        attr_accessor :parts, :instance

        def initialize(source_file:)
            @parts = {}
            @instance = Instance.new(source_file: source_file, catalog: self, catalog_path: nil)
            @instance.build
        end

        def add_category(catalog:, category:)
            entry_path = [catalog,category].join('/')
            add_parts_item(entry_path: entry_path, item: {})
            entry_path
        end
        
        def add_to_category(category:, item:)
            item_entry = {}
            item_entry[item.catalog_property] = item
            add_parts_item(entry_path: category, item: item_entry)
        end
        
        def get_item(entry_path:)
            puts("get_item: #{entry_path}") if DEBUG
            cursor = @parts
            entry_path = entry_path[1..-1] if entry_path[0] == '/'
            entry_path_split = entry_path.split('/')
            length = entry_path_split.length
            entry_path_split.each_with_index do |folder, index|
                p "folder: #{folder}, @index: #{index}"
                cursor = cursor[folder]
            end
            cursor
        end

        private
        
        def add_parts_item(entry_path:, item:)
            puts("add_parts_item: #{entry_path} item: #{item}") if DEBUG
            cursor = @parts
            entry_path = entry_path[1..-1] if entry_path[0] == '/'
            entry_path_split = entry_path.split('/')
            length = entry_path_split.length
            entry_path_split.each_with_index do |folder, index|
                is_last = (index == length-1)
                is_nil = cursor[folder].nil?
                p "folder: #{folder}, @index: #{index}, is_last: #{is_last}, is_nil: #{is_nil}"
                if is_nil
                    cursor[folder] = {}
                end
                if is_last
                    cursor[folder].merge!(item)
                end
                cursor = cursor[folder]
            end
            puts("@parts: #{@parts}") if DEBUG
        end
    end
end

