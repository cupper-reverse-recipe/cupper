require 'cupper/collect'

module Cupper
  class Generator
    def initialize
      @collector = Collect.new
    end

    def packages
      datas = @collector.extract_packages
    end
  end

end
