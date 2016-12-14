require "pathname"
require "cupper/cupperfile"
require "cupper/version"
require 'colorize'
require "cupper/errors"

module Cupper
  class Environment
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

    def check_env(ex, root_path)
      begin
        raise ex if !root_path 
      rescue ex => ex
        puts "#{ex.message}".red
      end
    end

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
      opts[:cupperfile_name] = 'Cupperfile'

      # Set the Cupperfile name up. We append "Cupperfile" and "cupperfile" so that
      # those continue to work as well, but anything custom will take precedence.
      opts[:cupperfile_name] ||= ENV["cupper_cupperFILE"] if \
        ENV.key?("cupper_cupperFILE")
      opts[:cupperfile_name] = [opts[:cupperfile_name]] if \
        opts[:cupperfile_name] && !opts[:cupperfile_name].is_a?(Array)

      # Set instance variables for all the configuration parameters.
      @cwd              = opts[:cwd]
      @cupperfile_name = opts[:cupperfile_name]


      # Run checkpoint in a background thread on every environment
      # initialization. The cache file will cause this to mostly be a no-op
      # most of the time.
      @checkpoint_thr = Thread.new do
        Thread.current[:result] = nil

        # If we disabled state and knowing what alerts we've seen, then
        # disable the signature file.
        signature_file = @data_dir.join("checkpoint_signature")
        if ENV["cupper_CHECKPOINT_NO_STATE"].to_s != ""
          signature_file = nil
        end

        Thread.current[:result] = Checkpoint.check(
          product: "cupper",
          version: VERSION,
          signature_file: signature_file,
          cache_file: @data_dir.join("checkpoint_cache"),
        )
      end

    end

    # Return a human-friendly string for pretty printed or inspected
    # instances.
    #
    # @return [String]
    def inspect
      "#<#{self.class}: #{@cwd}>".encode('external')
    end

    def config_loader
      return @config_loader if @config_loader

      root_cupperfile = nil
      if root_path
        root_cupperfile = find_cupperfile(root_path, @cupperfile_name)
      end

      @config_loader = Config::Loader.new()
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
      filenames ||= ["Cupperfile", "cupperfile"]
      filenames.each do |cupperfile|
        current_path = search_path.join(cupperfile)
        return current_path if current_path.file?
      end

      nil
    end

  end
end
