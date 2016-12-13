require "pathname"

require "log4r"

module Cupper
  module Config
    # This class is responsible for loading Cupper configuration,
    # usually in the form of Cupperfiles.
    #
    # Loading works by specifying the sources for the configuration
    # as well as the order the sources should be loaded. Configuration
    # set later always overrides those set earlier; this is how
    # configuration "scoping" is implemented.
    class Loader

    end
  end
end
