module LubuntuGui
    class Catalog
        attr_accessor :parts

        def initialize(source_file:)
            @parts = {}
            @instance = Instance.new(source_file: source_file, catalog: self, catalog_path: '/')
        end

        def add_item(entry_category:,catalog_path:, name:, item:)
            entry_path = [catalog_path, name].join('/')
            add_parts_item(entry_category:, entry_path:, item:)
        end

        private
        
        def add_parts_item(entry_category:, entry_path:, item:)
            cursor = @parts
            entry_path.split('/').each do |folder|
                cursor[folder] = {} if cursor[folder].nil?
                cursor = cursor[folder]
            end
            unless entry_path.split('/').last == entry_category
                cursor[entry_category] = {} if cursor[entry_category].nil?

            else
                cursor[entry_category] = item
            end
        end
    end
end

