# frozen_string_literal: true

module LubuntuGui
  # Manages application launching and desktop integration
  class Users < CollectorBase
    def initialize(source_file:)
      super
    end

    def name 
      'users'
    end
  end
end

