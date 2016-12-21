require 'cupper/version'
require 'cupper/project'
require 'cupper/cli'
require 'cupper/ohai_plugins'
require 'cupper/collect'
require 'cupper/cookbook'
require 'cupper/entity'
require 'cupper/config/loader'
require 'cupper/cupperfile'
require 'cupper/environment'
require 'cupper/errors'



module Cupper
  extend self
  CUPPER_ROOT       = File.expand_path(File.dirname(__FILE__))
  OHAI_PLUGINS_PATH = CUPPER_ROOT + '/cupper/plugins/ohai'
  CUPPER_PLUGINS_PATH = CUPPER_ROOT + '/cupper/plugins/cupper'
  TEMPLATE_PATH     = CUPPER_ROOT + '/cupper/templates'
  def parameter(*names)
    names.each do |name|
      attr_accessor name

      # For each given symbol we generate accessor method that sets option's
      # value being called with an argument, or returns option's current value
      # when called without arguments
      define_method name do |*values|
        value = values.first
        value ? self.send("#{name}=", value) : instance_variable_get("@#{name}")
      end
    end
  end

  # REVIEW: maybe there is a better way and place to load all plugins
  # Loading all cupper plugins
  Dir["#{CUPPER_PLUGINS_PATH}/*.rb"].each { |file| require file }
  def self.configure()
    self.config do
      parameter :native_configured
      parameter :sensible_files
      parameter :downgrade

      native_configured true
    end
    # TODO: raise stuff if mandatory stuff is not defined in cupperfile
  end
    # And we define a wrapper for the configuration block, that we'll use to set up
  # our set of options
  def config(&block)
    instance_eval &block
  end
end

