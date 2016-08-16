module Cupper
  # Entity represents a Entity
  module Entity
    require 'erb'

    FILE = 'file'
    DIR = 'dir'

    # As default the Entity is treated as a file
    def initialize
      @type = FILE
    end

    # Create the actual file or dir in the correct place
    def create(name, dest_path, type = nil)
      config(name, dest_path, type)
      content('_package.erb')
      save
    end

    # Set the attributes of the Entity
    def config(name, dest_path, type)
      @name = name
      @type = type if not type.nil?
      @dest_path = dest_path
      @full_path = "#{dest_path}/#{name}"
    end

    # Returns the content of the file
    def content(erb_file)
      return false if self.dir?
      @template = File.read(TEMPLATE_PATH + "/#{erb_file}")
    end

    def render
      ERB.new(@template).result(binding)
    end

    def save
      File.open(@full_path,"a+") do |f|
        f.write(render)
      end
    end

    # Treats entity as a file or as a dir
    def file?
      @type == FILE
    end
    def dir?
      @type == DIR
    end
  end

  class Attribute
    attr_reader :attr
  end

  # Represents the recipe of the cookbook
  class Recipe
    include Cupper::Entity
    def initialize
      @packages = Array.new
      setup
    end

    def setup
      @packages.push(new_package("pgsql","1.2.3"))
      @packages.push(new_package("mysql","3.5.3"))
      @packages.push(new_package("vim","4.2.1"))
      @packages
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
