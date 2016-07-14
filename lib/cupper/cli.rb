# This module defines all the class responsable for the command line tool
# It should call all the others module and classes to provides for the user
#   all the features avaible
#

require 'thor'
require 'cupper/config'

module Cupper
  class Cli < Thor
    desc "create [PROJECT_NAME]", "Create the project structure"
    def create(project_name)
      project = Project.new(project_name)
      project.create
    end
  end
end
