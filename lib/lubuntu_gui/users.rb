# frozen_string_literal: true

module LubuntuGui
  # Manages application launching and desktop integration
  class Users < CollectorBase
    def initialize(source_file:, catalog:, catalog_path:)
      super(source_file: source_file, catalog: catalog, catalog_path: nil)
      #File.join(source_file,'users')
    end
  end
end

