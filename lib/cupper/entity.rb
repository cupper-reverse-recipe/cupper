module Cupper
  # Entity represents a Entity
  module Entity
    require 'erb'

    FILE = 'file'
    DIR = 'dir'

    # As default the Entity is treated as a file
    def initialize(name, dest_path, erb_file = nil, type = nil, extension = '')
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

end
