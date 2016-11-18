require 'cupper/platform_collector'

module Cupper
  class Debian
    include PlatformCollector
    def packages(data_extraction)
      packages = Array.new
      duplicated = Array.new
      data_extraction['pkg_deps']['pkg_deps'].each do |dep|
        duplicated << dep[1]
      end
      duplicated.flatten!.uniq!
      data_extraction['packages']['packages'].each do |pkg|
        packages.push(pkg) unless duplicated.include? pkg[0]
      end
      packages
    end

    def files(data_extraction)
      files = Array.new
      data_extraction['files']['files'].each do |file|
        files.push(file)
      end
      files
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
