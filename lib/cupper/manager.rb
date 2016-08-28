require 'cupper/collect'
require 'cupper/recipe'

module Cupper
  class Cookbook
    # TODO: Read config file to tell the project path and configs
    def initialize
      @cookbook_path    = Dir.getwd.concat '/cookbooks'
    end

    def generate
      puts 'Generating Recipes ...'
      recipe = Recipe.new(@cookbook_path, '_package')
      recipe.create
    end
  end
end
