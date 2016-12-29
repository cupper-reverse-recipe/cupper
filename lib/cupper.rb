require 'cupper/version'
require 'cupper/project'
require 'cupper/cli'
require 'cupper/ohai_plugins'
require 'cupper/collect'
require 'cupper/cookbook'
require 'cupper/entity'
require 'cupper/config/config'
require 'cupper/cupperfile'
require 'cupper/environment'
require 'cupper/errors'



module Cupper
  CUPPER_ROOT         = File.expand_path(File.dirname(__FILE__))
  OHAI_PLUGINS_PATH   = CUPPER_ROOT + '/cupper/plugins/ohai'
  CUPPER_PLUGINS_PATH = CUPPER_ROOT + '/cupper/plugins/cupper'
  TEMPLATE_PATH       = CUPPER_ROOT + '/cupper/templates'
  ENVIRONMENT = Environment.new

  # REVIEW: maybe there is a better way and place to load all plugins
  # Loading all cupper plugins
  Dir["#{CUPPER_PLUGINS_PATH}/*.rb"].each { |file| require file }
end

