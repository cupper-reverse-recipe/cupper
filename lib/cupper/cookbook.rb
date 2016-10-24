require 'cupper/collect'
require 'cupper/recipe'
require 'cupper/cookbook_file'

module Cupper
  class Cookbook
    # TODO: Read config file to tell the project path and configs
    def initialize
      @cookbook_path    = "#{Dir.getwd}/cookbooks"
      @cookbook_files_path = "#{@cookbook_path}/files"
      setup_paths
    end

    def setup_paths
      Dir.mkdir(@cookbook_path) unless Dir.exists?(@cookbook_path)
      Dir.mkdir(@cookbook_files_path) unless Dir.exists?(@cookbook_files_path)
    end

    def generate
      collector = Collect.new
      collector.setup
      all_recipes(collector)
      all_cookbook_files(collector)
    end

    def all_recipes(collector)
      recipe = Recipe.new(@cookbook_path, collector, '_cookbook_file')
      recipe.create
    end

    def all_cookbook_files(collector)
      expand_cookbook_files(collector.extract 'files')
    end

    def text_type?(file)
      file[1]['type'].match('text') or file[1]['type'].match('ASCII')
    end

    def expand_cookbook_files(files)
      files.each do |attr|
        if text_type?(attr)
          source = attr[0].split('/').last
          content = attr[1]['content']
          cbf = CookbookFile.new(@cookbook_files_path, source, content, 'cookbook_file')
          cbf.create
        end
      end
    end
  end
end
