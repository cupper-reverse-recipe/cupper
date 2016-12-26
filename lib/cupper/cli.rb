# This module defines all the class responsable for the command line tool
# It should call all the others module and classes to provides for the user
#   all the features avaible
#

require 'thor'
require 'cupper/project'
require 'cupper/cookbook'
require 'cupper/ohai_plugins'
require 'cupper/environment'

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

    desc 'generate', 'Extract configuration and create a cookbook'
    method_option :verbose, :aliases => '-v', :desc => 'Enable output log'
    def generate
      puts "Generating the Cookbook..."

      puts "Setting up the environment"
      env = Environment.new
      env.check_env(Errors::NoEnvironmentError, env.root_path)
      config = env.cupperfile

      puts Config.sensible_files
      cookbook = Cookbook.new
      if options.verbose?
        puts "Verbose mode enabled"
        cookbook.generate
      else
        Cupper.suppress_output{ cookbook.generate }
      end
    end
  end

  # When necessary, use this method to supress outputs
  #   don't suppress Exeptions
  def self.suppress_output
    begin
      origin_stderr = $stderr.clone
      origin_stdout = $stdout.clone
      $stderr.reopen(File.new('/dev/null', 'w'))
      $stdout.reopen(File.new('/dev/null', 'w'))
      retval = yield
    rescue Exception => e
      $stderr.reopen(origin_stderr)
      $stdout.reopen(origin_stdout)
      raise e
    ensure
      $stderr.reopen(origin_stderr)
      $stdout.reopen(origin_stdout)
    end
    retval
  end
end
