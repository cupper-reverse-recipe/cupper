require "pathname"
require "cupper/errors"
require 'colorize'
require 'configuration'


module Cupper
  module Config

    class Loader
      def initialize()
        @config_cache  = {}
        @sources       = {}
      end

      def load(cupperfile)
        Kernel.load cupperfile

        if defined? Cupper.native_configured
          result = Cupper
        else
          result = Configuration.for 'Cupperfile'
        end

        puts "Configuration loaded successfully, finalizing and returning"
        return result
      end

    end
  end
end
