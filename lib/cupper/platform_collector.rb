# REVIEW: This should be review in some point in the future
# The PlatformCollector is a module that defines all the methods used to extract
#   the information about the platform. It is a little pointless in terms of implementation
#   but is good to know what method should be implemented.

module Cupper
  module PlatformCollector
    def packages
      raise NotImplementedError
    end

    def links
      raise NotImplementedError
    end

    def services
      raise NotImplementedError
    end

    def users
      raise NotImplementedError
    end

    def executes
      raise NotImplementedError
    end

    def directory
      raise NotImplementedError
    end

    def files
      raise NotImplementedError
    end

    def templates
      raise NotImplementedError
    end
  end
end
