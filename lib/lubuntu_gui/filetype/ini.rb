module LubuntuGui
    # Manages application launching and desktop integration
  class Ini < ItemBase  
    
    def initialize(catalog:, catalog_path:, source_file:)
      super
      file = IniFile.load(source_file_with_extension)
    end

    def source_file_with_extension
      @source_file + ".ini"
    end

    def catalog_property
      "ini"
    end
  
  end
end