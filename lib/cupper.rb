require 'cupper/version'
require 'cupper/project'
require 'cupper/cli'
require 'cupper/ohai_plugins'
require 'cupper/collect'
require 'cupper/manager'
require 'cupper/entity'

module Cupper
  CUPPER_ROOT       = File.expand_path(File.dirname(__FILE__))
  OHAI_PLUGINS_PATH = CUPPER_ROOT + '/cupper/plugins/ohai'
  TEMPLATE_PATH     = CUPPER_ROOT + '/cupper/templates'
end

