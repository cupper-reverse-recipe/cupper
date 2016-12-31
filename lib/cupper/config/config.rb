require "pathname"
require "cupper/errors"
require 'colorize'


module Cupper
  module Config
    extend self

    def parameter(*names)
      names.each do |name|
        attr_accessor name

        # For each given symbol we generate accessor method that sets option's
        # value being called with an argument, or returns option's current value
        # when called without arguments
        define_method name do |*values|
          value = values.first
          value ? self.send("#{name}=", value) : instance_variable_get("@#{name}")
        end
      end
    end

    def self.configure
      self.config do
        parameter :native_configured
        parameter :sensible_files
        parameter :allow_downgrade
        parameter :sourceless_packages

        native_configured true
      end
      # TODO: raise stuff if mandatory stuff is not defined in cupperfile
    end

    def config(&block)
      instance_eval &block
    end

    def load(cupperfile)
      Kernel.load cupperfile
      result = Cupper::Config

      puts "Configuration loaded successfully, finalizing and returning"
      return result
    end

    def self.all_sensibles
      sensibles = Array.new
      unless sensible_files
        env = Cupper::ENVIRONMENT
        File.open("#{env.root_path}/.sensibles").each do |line|
          sensibles.push line.chomp unless line.strip.chomp.match /^#.*/ or line.chomp.empty?
        end
      end
      sensibles
    end
  end
end
