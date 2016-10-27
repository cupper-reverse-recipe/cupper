require 'ohai'
require 'cupper/ohai_plugins'

module Cupper
  class Collect
    ADDITIONAL_OHAI_PLUGINS = [
      'packages',
      'platform_family',
      'etc'
    ]

    def initialize
      @data_extraction = Hash.new('No data!')
      @ohai = Ohai::System.new
      @ohai_plugin = OhaiPlugin.new

      # TODO: Ohai::Config[:plugin_path] is decrepted
      @plugins_path = Cupper::OHAI_PLUGINS_PATH
      Ohai::Config[:plugin_path] << @plugins_path
    end

    def extract(attribute)
      begin
        object = 'Cupper::'.concat self.platform.capitalize
        platform = Object.const_get(object).new
        extract = platform.method attribute
        extract.call @data_extraction
      rescue NameError
        puts 'Not supported platform' # TODO: treat this better
      end
    end

    def setup
      plugins = @ohai_plugin.list
      plugins.concat ADDITIONAL_OHAI_PLUGINS
      plugins.each do |plugin|
        extract = @ohai.all_plugins(plugin)
        @data_extraction.update({ plugin => extract.first.data }) # Assuming that the first is the default plugin extractor
      end
      true
    end

    def platform
      @data_extraction['platform_family']['platform_family']
    end

    def data
      @data_extraction
    end
  end
end
