require 'cupper/collect'
require 'cupper/recipe'
require 'cupper/cookbook_file'

module Cupper
  class Cookbook
    # TODO: Read config file to tell the project path and configs
    def initialize(cookbookname='default')
      @cookbook_path    = "#{Dir.getwd}/cookbooks/#{cookbookname}"
      @cookbook_files_path = "#{@cookbook_path}/files"
      @cookbook_recipes_path = "#{@cookbook_path}/recipes"
      @recipe_deps = [ # TODO this is hard code to reflect all_recipes. Refactor this later
        "#{cookbookname}::packages",
        "#{cookbookname}::cookbook_files",
        "#{cookbookname}::links",
        "#{cookbookname}::groups",
        "#{cookbookname}::services",
        "#{cookbookname}::users",
      ]
      setup_paths
    end

    def setup_paths
      Dir.mkdir(@cookbook_path) unless Dir.exists?(@cookbook_path)
      Dir.mkdir(@cookbook_files_path) unless Dir.exists?(@cookbook_files_path)
      Dir.mkdir(@cookbook_recipes_path) unless Dir.exists?(@cookbook_recipes_path)
    end

    def generate
      collector = Collect.new
      collector.setup
      all_recipes(collector)
    end

    def all_recipes(collector)
      Recipe.new(@cookbook_recipes_path, collector, 'recipe', 'default', @recipe_deps).create
      Recipe.new(@cookbook_recipes_path, collector, '_cookbook_file', 'cookbook_files').create
      Recipe.new(@cookbook_recipes_path, collector, '_links', 'links').create
      Recipe.new(@cookbook_recipes_path, collector, '_groups', 'groups').create
      Recipe.new(@cookbook_recipes_path, collector, '_services', 'services').create
      Recipe.new(@cookbook_recipes_path, collector, '_users', 'users').create
      Recipe.new(@cookbook_recipes_path, collector, '_package', 'packages').create
    end
  end
end
