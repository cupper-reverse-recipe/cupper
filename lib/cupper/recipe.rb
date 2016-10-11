
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
      @groups       = Array.new
      @execute      = Array.new
      @links        = Array.new
      @directories  = Array.new
      @files        = Array.new
      super('recipe',dest_path,erb_file,type,'.rb')
    end

    def create
      collector = Collect.new
      collector.setup
      @packages = expand_packages(collector.extract 'packages')
      @services = expand_services(collector.extract 'services')
      @users    = expand_users(collector.extract 'users')
      @groups   = expand_groups(collector.extract 'groups')
      @links    = expand_links(collector.extract 'files')
      @files    = expand_files(collector.extract 'files')
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

    def convert_mode(mode)
      # This abord the commons modes for files
      return 'ERROR' if not mode
      result = case mode.split('').last(9).join
               when 'rwxrwxrwx' then '777'
               when 'rwxr-xr-x' then '755'
               when 'rwx------' then '700'
               when 'rw-rw-rw-' then '666'
               when 'rw-r--r--' then '644'
               when 'rw-------' then '600'
               else 'Unknown'
               end
      result
    end

    def expand_services(services)
      att = Array.new
      services.each do |attr|
        srv = attr[0]
        action = attr[1]['action']

        att.push(new_service(srv,action))
      end
      att
    end

    def expand_links(links)
      att = Array.new
      links.each do |attr|
        if link?(attr)
          target = attr[0]
          to = attr[1]['type'].split.last(1).join
          group = attr[1]['group']
          mode = attr[1]['mode']
          owner = attr[1]['owner']

          att.push(new_link(group, convert_mode(mode), owner, target, to))
        end
      end
      att
    end

    def expand_users(users)
      att = Array.new
      users.each do |attr|
        usr = attr[0]
        uid = attr[1]['uid']
        gid = attr[1]['gid']
        dir = attr[1]['dir']
        shell = attr[1]['shell']

        att.push(new_user(usr, uid, gid, dir, shell))
      end
      att
    end

    def expand_groups(groups)
      att = Array.new
      groups.each do |attr|
        grp = attr[0]
        gid = attr[1]['gid']
        members = attr[1]['members']

        att.push(new_group(grp, gid, members))
      end
      att
    end

    def expand_files(files)
      att = Array.new
      files.each do |attr|
        unless link?(attr)
          target = attr[0]
          group = attr[1]['group']
          mode = attr[1]['mode']
          owner = attr[1]['owner']

          att.push(new_file(group, convert_mode(mode), owner))
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

    def new_user(name, uid, gid, dir, shell)
      user = Attribute.new
      class << user
        attr_accessor :name
        attr_accessor :uid
        attr_accessor :gid
        attr_accessor :dir
        attr_accessor :shell
      end
      user.name         = name
      user.uid          = uid 
      user.gid          = gid
      user.dir          = dir
      user.shell        = shell 
      user
    end

    def new_group(name, gid, members)
      group = Attribute.new
      class << group
        attr_accessor :name
        attr_accessor :gid
        attr_accessor :members
      end
      group.name         = name
      group.gid          = gid
      group.members      = members
      group
    end
    
    def new_execute(command)
    end

    def new_directory()
    end

    def new_file(group, mode, owner)
      file = Attribute.new
      class << file
        attr_accessor :path
        attr_accessor :source
        attr_accessor :group
        attr_accessor :mode
        attr_accessor :owner
      end
      file.path         = 'path'
      file.source       = 'source'
      file.group        = group
      file.mode         = mode
      file.owner        = owner
      file
    end
  end
end
