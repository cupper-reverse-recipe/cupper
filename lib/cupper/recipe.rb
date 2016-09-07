
module Cupper
  # Represents the recipe of the cookbook
  # TODO: This is just a example, it's should be changed to another file
  class Recipe
    include Entity
    def initialize(dest_path, erb_file = nil, type = nil)
      @packages     = Array.new
      @services     = Array.new
      @templates    = Array.new
      @users        = Array.new
      @execute      = Array.new
      @links        = Array.new
      @directories  = Array.new
      @files        = Array.new
      super('recipe',dest_path,erb_file,type,'.rb')
    end

    def create
      collector = Collect.new
      @packages = expand_packages(collector.extract 'packages')
      @links    = expand_links(collector.extract 'links')
      super
    end

    def expand_packages(packages)
      att = Array.new
      packages.each do |attr|
        pkg = attr[0]
        version = attr[1]['version']

        att.push(new_package(pkg,version))
      end
      att
    end

    def link?(file)
      (file[1]['type'].split.first(2).join(' ').match('symbolic link'))
    end

    def expand_links(links)
      att = Array.new
      links.each do |attr|
        if link?(attr)
          target = attr[0]
          to = attr[1]['type'].split.last(1).join

          att.push(new_link(nil, nil, nil, target, to))
        end
      end
      att
    end

    # Every attribute object is created dynamic
    def new_package(name, version)
      package = Attribute.new
      class << package
        attr_accessor :name
        attr_accessor :version
      end
      package.name = name
      package.version = version
      package
    end

    def new_service(name, action)
      service = Attribute.new
      class << service
        attr_accessor :name
        attr_accessor :action
      end
      service.name = name
      service.action = action
      service
    end

    def new_link(group, mode, owner, target_file, to)
      link = Attribute.new
      class << link
        attr_accessor :group
        attr_accessor :mode
        attr_accessor :owner
        attr_accessor :target_file
        attr_accessor :to
      end
      link.group        = group
      link.mode         = mode
      link.owner        = owner
      link.target_file  = target_file
      link.to           = to
      link
    end

    def new_template(path, source, owner, group, mode)
    end

    def new_user(name)
    end
    
    def new_execute(command)
    end

    def new_directory()
    end

    def new_file()
    end
  end
end