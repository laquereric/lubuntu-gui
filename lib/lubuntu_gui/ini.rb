module LubuntuGui
    # Manages application launching and desktop integration
  class Ini < ItemBase  
    def initialize(catalog:, catalog_path:, source_file:)
      file = IniFile.load(source_file)
      #data = file["Desktop Entry"]
      #@desktop_entry = data
      super
    end
  end
end