module Cupper
  # Entity represents a Entity
  module Entity
    require 'erb'

    FILE = 'file'
    DIR = 'dir'

    # As default the Entity is treated as a file
    def initialize(name, dest_path, type = nil, erb_file = nil, extension = '')
      @name = name
      @dest_path = dest_path
      @erb_file = erb_file
      @type = type.nil? ? FILE : type
      @ext = extension

      @full_path = "#{@dest_path}/#{@name}#{@ext}"
    end

    # Create the actual file or dir in the correct place
    def create
      content(@erb_file)
      save
    end

    # Returns the content of the file
    def content(erb_file)
      return false if self.dir?
      @template = File.read(TEMPLATE_PATH + "/#{erb_file}.erb")
    end

    def save
      return false if self.exist?
      File.open(@full_path,"a+") { |f| f.write(self.render) } if self.file?
      Dir.mkdir(@full_path) if self.dir?
    end

    def render
      ERB.new(@template).result(binding)
    end

    # Treats entity as a file or as a dir
    def file?
      @type == FILE
    end
    def dir?
      @type == DIR
    end

    def exist?
      File.exist?(@full_path) if self.file?
      Dir.exist?(@full_path) if self.dir?
    end
  end

  class Attribute
    attr_reader :attr
  end

  # Represents the recipe of the cookbook
  # TODO: This is just a example, it's should be changed to another file
  class Recipe
    include Cupper::Entity
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
