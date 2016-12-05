
module Cupper
  # Represents the recipe of the cookbook
  class Recipe
    include Entity
    def initialize(dest_path, collector, erb_file = nil, recipe_name = 'default', recipe_deps = nil)
      @recipe_deps  = recipe_deps
      @packages     = Array.new
      @services     = Array.new
      @templates    = Array.new
      @users        = Array.new
      @groups       = Array.new
      @execute      = Array.new
      @links        = Array.new
      @directories  = Array.new
      @files        = Array.new
      @files_path   = "#{dest_path.chomp("recipes")}/files"
      @collector    = collector
      super(recipe_name, dest_path, erb_file, nil, '.rb')
    end

    def create
      @sources_list   = expand_sources_list(@collector.extract 'files')
      @packages       = expand_packages(@collector.extract 'packages')
      @services       = expand_services(@collector.extract 'services')
      @users          = expand_users(@collector.extract 'users')
      @groups         = expand_groups(@collector.extract 'groups')
      @links          = expand_links(@collector.extract 'files')
      @files          = expand_files(@collector.extract 'files')
      super
    end

    def link_type?(file)
      (file[1]['type'].split.first(2).join(' ').match('symbolic link'))
    end

    def dir_type?(file)
      file[1]['type'].match('directory')
    end

    def text_type?(file)
      file[1]['type'].match('text') or file[1]['type'].match('ASCII')
    end

    # TODO: this should be on ohai plugin
    def convert_mode(mode)
      return 'ERROR' if not mode
      result = case mode.split('').last(9).join # Common modes
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


    def expand_sources_list(files)
      att = Array.new
      files.each do |attr|
        # TODO: Doesn't works for arch, this should be a plugin responsability
        if attr[0].include?("/etc/apt/sources.list") and (convert_mode(attr[1]['mode']) != 'Unknown') and text_type?(attr)
          path = attr[0]
          group = attr[1]['group']
          mode = attr[1]['mode']
          owner = attr[1]['owner']
          att.push(new_file(group, mode, owner, path))
        end
      end
      att
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
        if link_type?(attr)
          target = attr[0]
          to = attr[1]['type'].split.last(1).join
          group = attr[1]['group']
          mode = attr[1]['mode']
          owner = attr[1]['owner']

          att.push(new_link(group, mode, owner, target, to))
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
        if text_type?(attr) and (!(attr[1]['related'].nil?) or attr[0].include? "/etc/apt/sources.list")
          path = attr[0]
          group = attr[1]['group']
          mode = attr[1]['mode']
          owner = attr[1]['owner']
          att.push(new_file(group, mode, owner, path))

          # Related file
          source = attr[0].split('/').last
          content = attr[1]['content']
          CookbookFile.new(@files_path, source, content, 'cookbook_file').create
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
      link.mode         = convert_mode(mode)
      link.owner        = owner
      link.target_file  = target_file
      link.to           = to
      link
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
    
    def new_file(group, mode, owner, path, source='')
      file = Attribute.new
      class << file
        attr_accessor :path
        attr_accessor :source
        attr_accessor :group
        attr_accessor :mode
        attr_accessor :owner
      end
      file.path         = path
      file.source       = source
      file.group        = group
      file.mode         = convert_mode(mode)
      file.owner        = owner
      file
    end
  end
end
