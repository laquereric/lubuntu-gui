module LubuntuGui
    class Catalog
        attr_accessor :parts, :instance

        def initialize(source_file:)
            @parts = {}
            @instance = Instance.new(source_file: source_file, catalog: self, catalog_path: nil)
        end

        def add_item( catalog_path:, entry_category:, item:)
            entry_path = [catalog_path, entry_category].compact.join('/')
            add_parts_item(entry_path:, item:)
            catalog_path
        end

        private
        
        def add_parts_item(entry_path:, item:)
            puts("add_parts_item: #{entry_path} item: #{item}") if DEBUG
            cursor = @parts
            length = entry_path.split('/').length
            entry_path.split('/').each_with_index do |folder, index|
                is_last = index == length - 1
                is_nil = cursor[folder].nil?
                p "folder #{folder}, @index, #{index}, is_last: #{is_last}, is_nil: #{is_nil}"
                if cursor[folder].nil?
                    if is_last
                        cursor[folder] = item
                    else
                        cursor[folder] = {}
                    end
                else
                    raise "collision: #{folder}"
                end
                
            end
            puts("@parts: #{@parts}") if DEBUG
            #entry_path.split('/')[-1] = item
            #puts("@parts: #{parts}") if DEBUG
            #unless entry_path.split('/').last == entry_category
            #    cursor[entry_category] = {} if cursor[entry_category].nil?
            #else
            #    cursor[entry_category] = item
            #end
        end
    end
end

