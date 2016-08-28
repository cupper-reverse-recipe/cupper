
module Cupper
  # Represents the recipe of the cookbook
  # TODO: This is just a example, it's should be changed to another file
  class Recipe
    include Entity
    def initialize(dest_path, erb_file = nil, type = nil)
      @packages   = Array.new
      @services    = Array.new
      @templates   = Array.new
      @users       = Array.new
      @execute    = Array.new
      @links       = Array.new
      @directories  = Array.new
      @files       = Array.new
      super('recipe',dest_path,erb_file,type)
    end

    def create
      collector = Collect.new
      @packages = expand(collector.extract 'packages')
      super
    end

    def expand(attribute)
      att = Array.new
      attribute.each do |attr|
        att.push(new_package(attr[0],attr[1]['version']))
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

    def new_template(path, source, owner, group, mode)
    end

    def new_user(name)
    end
    
    def new_execute(command)
    end

    def new_link(source, link_path)
    end

    def new_directory()
    end

    def new_file()
    end
  end
end
