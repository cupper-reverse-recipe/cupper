# This module prepare the Cupper project with the
#   defaults files and dirs. All the files created are
#   just samples and must to be changed by the user
require 'cupper/entity'

module Cupper
  class Structure
    include Entity
    def initialize(name,dest_path, type = nil, erb_file = nil)
      super(name, dest_path, type, erb_file)
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
        'CupperFile'
      ]
    end

    def create
      # Root project directory
      struct = Structure.new(@name, @dir, Entity::DIR)
      struct.create

      @subdirs.zip(@files).each do |dir, file|
        Structure.new(dir, "#{@dir}/#{@name}", Entity::DIR).create
        Structure.new(file, "#{@dir}/#{@name}", nil, file).create
      end
    end
  end
end
