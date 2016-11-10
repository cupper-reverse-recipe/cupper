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

  # REVIEW: This should be review in some point in the future
  # The PlatformCollector is a module that defines all the methods used to extract
  #   the information about the platform. It is a little pointless in terms of implementation
  #   but is good to know what method should be implemented.
  module PlatformCollector

    def packages
      raise NotImplementedError
    end

    def links
      raise NotImplementedError
    end
    
    def services
      raise NotImplementedError
    end

    def users
      raise NotImplementedError
    end

    def groups
      raise NotImplementedError
    end

    def executes
      raise NotImplementedError
    end

    def directory
      raise NotImplementedError
    end

    def files
      raise NotImplementedError
    end

    def templates
      raise NotImplementedError
    end
  end

  class Debian
    include PlatformCollector
    def packages(data_extraction)
      packages = Array.new
      data_extraction['packages']['packages'].each do |pkg|
        packages.push(pkg)
      end
      packages
    end

    def links(data_extraction)
      links = Array.new
      data_extraction['files']['files'].each do |file|
        links.push(file)
      end
      links
    end

    def services(data_extraction)
      services = Array.new
      data_extraction['services']['services'].each do |service|
        services.push(service)
      end
    end

    def users(data_extraction)
      users = Array.new
      data_extraction['etc']['etc']['passwd'].each do |user|
        users.push(user)
      end
    end

    def groups(data_extraction)
      groups = Array.new
      data_extraction['etc']['etc']['group'].each do |group|
        groups.push(group)
      end
    end
  end

  class Arch
    include PlatformCollector
    def packages(data_extraction)
      packages = Array.new
      data_extraction['pacman']['pacman'].each do |pkg|
        packages.push(pkg)
      end
      packages
    end

    def links(data_extraction)
      links = Array.new
      data_extraction['files']['files'].each do |file|
        links.push(file)
      end
      links
    end

    def services(data_extraction)
      services = Array.new
      data_extraction['services']['services'].each do |service|
        services.push(service)
      end
    end

    def users(data_extraction)
      users = Array.new
      data_extraction['etc']['etc']['passwd'].each do |user|
        users.push(user)
      end
    end

    def groups(data_extraction)
      groups = Array.new
      data_extraction['etc']['etc']['group'].each do |group|
        groups.push(group)
      end
    end
  end
end
