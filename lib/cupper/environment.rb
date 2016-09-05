require "cupper/cupperfile"
require "cupper/version"

module Cupper
  class Enviroment
    # The `cwd` that this environment represents
    attr_reader :cwd

    # The persistent data directory where global data can be stored. It
    # is up to the creator of the data in this directory to properly
    # remove it when it is no longer needed.
    #
    # @return [Pathname]
    attr_reader :data_dir

    # The valid name for a Cupperfile for this environment.
    attr_reader :cupperfile_name

    # The directory to the directory where local, environment-specific
    # data is stored.
    attr_reader :local_data_path

    # The directory where temporary files for Cupper go.
    attr_reader :tmp_path

    # The path where the plugins are stored (gems)
    attr_reader :gems_path

    # Initializes a new environment with the given options. The options
    # is a hash where the main available key is `cwd`, which defines where
    # the environment represents. There are other options available but
    # they shouldn't be used in general. If `cwd` is nil, then it defaults
    # to the `Dir.pwd` (which is the cwd of the executing process).
    def initialize(opts=nil)
      opts = {
        cwd:              nil,
        local_data_path:  nil,
        cupperfile_name: nil,
      }.merge(opts || {})

      # Set the default working directory to look for the cupperfile
      opts[:cwd] ||= ENV["cupper_CWD"] if ENV.key?("cupper_CWD")
      opts[:cwd] ||= Dir.pwd
      opts[:cwd] = Pathname.new(opts[:cwd])
      if !opts[:cwd].directory?
        raise Errors::EnvironmentNonExistentCWD, cwd: opts[:cwd].to_s
      end
      opts[:cwd] = opts[:cwd].expand_path

      # Set the Cupperfile name up. We append "Cupperfile" and "cupperfile" so that
      # those continue to work as well, but anything custom will take precedence.
      opts[:cupperfile_name] ||= ENV["cupper_cupperFILE"] if \
        ENV.key?("cupper_cupperFILE")
      opts[:cupperfile_name] = [opts[:cupperfile_name]] if \
        opts[:cupperfile_name] && !opts[:cupperfile_name].is_a?(Array)

      # Set instance variables for all the configuration parameters.
      @cwd              = opts[:cwd]
      @cupperfile_name = opts[:cupperfile_name]

      # This is the batch lock, that enforces that only one {BatchAction}
      # runs at a time from {#batch}.

      @logger = Log4r::Logger.new("cupper::environment")
      @logger.info("Environment initialized (#{self})")
      @logger.info("  - cwd: #{cwd}")



      # Run checkpoint in a background thread on every environment
      # initialization. The cache file will cause this to mostly be a no-op
      # most of the time.
      @checkpoint_thr = Thread.new do
        Thread.current[:result] = nil

        # If we disabled checkpoint via env var, don't run this
        if ENV["cupper_CHECKPOINT_DISABLE"].to_s != ""
          @logger.info("checkpoint: disabled from env var")
          next
        end

        # If we disabled state and knowing what alerts we've seen, then
        # disable the signature file.
        signature_file = @data_dir.join("checkpoint_signature")
        if ENV["cupper_CHECKPOINT_NO_STATE"].to_s != ""
          @logger.info("checkpoint: will not store state")
          signature_file = nil
        end

        Thread.current[:result] = Checkpoint.check(
          product: "cupper",
          version: VERSION,
          signature_file: signature_file,
          cache_file: @data_dir.join("checkpoint_cache"),
        )
      end

      # Setup the local data directory. If a configuration path is given,
      # it is expanded relative to the root path. Otherwise, we use the
      # default (which is also expanded relative to the root path).
      if !root_path.nil?
        if !(ENV["cupper_DOTFILE_PATH"] or "").empty? && !opts[:child]
          opts[:local_data_path] ||= root_path.join(ENV["cupper_DOTFILE_PATH"])
        else
          opts[:local_data_path] ||= root_path.join(DEFAULT_LOCAL_DATA)
        end
      end
      if opts[:local_data_path]
        @local_data_path = Pathname.new(File.expand_path(opts[:local_data_path], @cwd))
      end
      @logger.debug("Effective local data path: #{@local_data_path}")


      setup_local_data_path

      # Setup the default private key
      @default_private_key_path = @home_path.join("insecure_private_key")
      copy_insecure_private_key

      # Call the hooks that does not require configurations to be loaded
      # by using a "clean" action runner
      hook(:environment_plugins_loaded, runner: Action::Runner.new(env: self))

      # Call the environment load hooks
      hook(:environment_load, runner: Action::Runner.new(env: self))
    end

    # Return a human-friendly string for pretty printed or inspected
    # instances.
    #
    # @return [String]
    def inspect
      "#<#{self.class}: #{@cwd}>".encode('external')
    end

    def setup_local_data_path(force=false)
      if @local_data_path.nil?
        @logger.warn("No local data path is set. Local data cannot be stored.")
        return
      end

      @logger.info("Local data path: #{@local_data_path}")

      # If the local data path is a file, then we are probably seeing an
      # old (V1) "dotfile." In this case, we upgrade it. The upgrade process
      # will remove the old data file if it is successful.
      if @local_data_path.file?
        upgrade_v1_dotfile(@local_data_path)
      end

      # If we don't have a root path, we don't setup anything
      return if !force && root_path.nil?

      begin
        @logger.debug("Creating: #{@local_data_path}")
        FileUtils.mkdir_p(@local_data_path)
      rescue Errno::EACCES
        raise Errors::LocalDataDirectoryNotAccessible,
          local_data_path: @local_data_path.to_s
      end
    end

    def config_loader
      return @config_loader if @config_loader

      root_cupperfile = nil
      if root_path
        root_cupperfile = find_cupperfile(root_path, @cupperfile_name)
      end

      @config_loader = Config::Loader.new(
        Config::VERSIONS, Config::VERSIONS_ORDER)
      @config_loader.set(:root, root_cupperfile) if root_cupperfile
      @config_loader
    end

    def environment(cupperfile, **opts)
      path = File.expand_path(cupperfile, root_path)
      file = File.basename(path)
      path = File.dirname(path)

      Util::SilenceWarnings.silence! do
        Environment.new({
          child:     true,
          cwd:       path,
          home_path: home_path,
          ui_class:  ui_class,
          cupperfile_name: file,
        }.merge(opts))
      end
    end

    def hook(name, opts=nil)
      @logger.info("Running hook: #{name}")
      opts ||= {}
      opts[:callable] ||= Action::Builder.new
      opts[:runner] ||= action_runner
      opts[:action_name] = name
      opts[:env] = self
      opts.delete(:runner).run(opts.delete(:callable), opts)
    end

    def root_path
      return @root_path if defined?(@root_path)

      root_finder = lambda do |path|
        # Note: To remain compatible with Ruby 1.8, we have to use
        # a `find` here instead of an `each`.
        vf = find_cupperfile(path, @cupperfile_name)
        return path if vf
        return nil if path.root? || !File.exist?(path)
        root_finder.call(path.parent)
      end

      @root_path = root_finder.call(cwd)
    end

    def unload
      hook(:environment_unload)
    end

    def cupperfile
      @cupperfile ||= cupperfile.new(config_loader, [:home, :root])
    end

    def find_cupperfile(search_path, filenames=nil)
      filenames ||= ["cupperfile", "cupperfile"]
      filenames.each do |cupperfile|
        current_path = search_path.join(cupperfile)
        return current_path if current_path.file?
      end

      nil
    end

  end
end
