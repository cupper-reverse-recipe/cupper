module Cupper
  class OhaiPlugin

    attr_reader :plugins_path

    def list_plugins
      @plugins_path = File.expand_path '../../cupper/plugins/ohai', __FILE__
      @plugins = Dir.entries(@plugins_path).reject{ |entry| entry == '.' || entry == '..'  }
      @plugins.each { |plugin| plugin.chomp(".rb") }
      @plugins
    end
  end
end
