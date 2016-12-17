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
        result = Configuration.for 'Cupperfile'

        puts "Configuration loaded successfully, finalizing and returning"
        return result
      end

    end
  end
end
