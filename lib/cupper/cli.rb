# This module defines all the class responsable for the command line tool
# It should call all the others module and classes to provides for the user
#   all the features avaible
#

require 'thor'
require 'cupper/project'
require 'cupper/ohai_plugins'

module Cupper
  class Cli < Thor
    desc 'create [PROJECT_NAME]', 'Create the project structure'
    def create(project_name)
      project = Project.new(project_name)
      project.create
    end

    desc 'ohai', 'List Ohai plugins'
    def ohai_plugins
      ohai_plugins = OhaiPlugin.new
      plugins = ohai_plugins.list
      puts "Ohai Plugins"
      puts "------------"
      plugins.each do |plugin|
        puts plugin
      end
    end
  end
end
