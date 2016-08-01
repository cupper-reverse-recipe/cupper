module Cupper
  class Collect
    require 'ohai'
    require 'cupper/ohai_plugins'

    def initializer
      @datas_extraction = Hash.new("No data!")
      @ohai = Ohai::System.new
      @ohai_plugins = Cupper::OhaiPlugin.new

      @plugins_path = File.expand_path 'plugins/ohai', __File__
      Ohai::Config[:plugin_path] << @plugins_path
    end

    def extract
      plugins = @ohai_plugins.list
      plugins.each do |plugin|
        extract = @ohai.all_plugins(plugin)
        @datas_extraction = { plugin => extract.first.data } # Assuming that the first is the default plugin extractor
      end
      @datas_extraction
    end
  end
end
