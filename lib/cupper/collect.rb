require 'ohai'
require 'cupper/ohai_plugins'

module Cupper
  class Collect

    attr_reader :data_extraction

    def initialize
      @data_extraction = Hash.new("No data!")
      @ohai = Ohai::System.new
      @ohai_plugin = OhaiPlugin.new

      @plugins_path = Cupper::OHAI_PLUGINS_PATH
      Ohai::Config[:plugin_path] << @plugins_path
    end

    def extract
      plugins = @ohai_plugin.list
      plugins.each do |plugin|
        extract = @ohai.all_plugins(plugin)
        @data_extraction.update({ plugin => extract.first.data }) # Assuming that the first is the default plugin extractor
      end
    end
  end
end
