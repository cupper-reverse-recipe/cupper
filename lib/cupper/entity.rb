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
      @template = File.read("#{TEMPLATE_PATH}/#{erb_file}.erb")
    end

    def save
      File.open(@full_path,"w+") { |f| f.write(self.render_template) } if self.file?
      Dir.mkdir(@full_path) if self.dir? && !(self.exist?)
    end

    def render_template
      ERB.new(@template, 0, '-').result(binding)
    end

    # Treats entity as a file or as a dir
    def file?
      @type == FILE
    end
    def dir?
      @type == DIR
    end

    def exist?
      return File.exist?(@full_path) if self.file?
      return Dir.exist?(@full_path) if self.dir?
    end

    def full_path
      @full_path
    end
  end

  class Attribute
    attr_reader :attr
  end

end
