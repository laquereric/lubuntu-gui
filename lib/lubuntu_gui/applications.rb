# frozen_string_literal: true

module LubuntuGui

  
  # Manages application launching and desktop integration
  class Applications < CollectorBase
    attr_accessor :desktop_entry

    def initialize(catalog:, catalog_path:, source_file:)
      super
    end
  
  end
end
