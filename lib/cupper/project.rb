# This module prepare the Cupper project with the
#   defaults files and dirs. All the files created are
#   just samples and must to be changed by the user
require 'cupper/entity'

module Cupper
  class Structure
    include Entity
    def initialize(name,dest_path, erb_file = nil, type = nil)
      super(name, dest_path, erb_file, type)
    end
  end

  class Project
    attr_reader :name
    attr_reader :dir

    def initialize(project_name, directory = nil)
      @name = project_name
      @dir = directory.nil? ? Dir.getwd : directory
      @subdirs = [
        'cookbooks'
      ]
      @files = [
        'Cupperfile',
      ]
      # TODO: this should not be separated from the others
      #   files. Try to get them together.
      @hidden = [
        'sensibles'
      ]
    end

    def create
      # Root project directory
      struct = Structure.new(@name, @dir, nil, Entity::DIR)
      struct.create

      @subdirs.zip(@files).each do |dir, file|
        Structure.new(dir, "#{@dir}/#{@name}", nil, Entity::DIR).create
        Structure.new(file, "#{@dir}/#{@name}", file).create
      end

      @hidden.each do |file|
        Structure.new(".#{file}", "#{@dir}/#{@name}", file).create
      end
    end
  end
end
