
module Cupper
  # Represents the recipe of the cookbook
  # TODO: This is just a example, it's should be changed to another file
  class Recipe
    include Entity
    def initialize(dest_path, type = nil, erb_file = nil)
      @packages = Array.new
      super("recipe",dest_path,type,erb_file)
    end

    def setup
      collector = Collect.new
      collector.extract_packages.each do |pkg_info|
        package = new_package(pkg_info[0],pkg_info[1]['version'])
        @packages.push(package)
      end
    end

    def new_package(name, version)
      package = Attribute.new
      class << package
        attr_accessor :name
        attr_accessor :version
      end
      package.name = name
      package.version = version
      package
    end
  end
end
