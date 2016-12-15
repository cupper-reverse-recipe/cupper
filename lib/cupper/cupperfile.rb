module Cupper
  class Cupperfile

    def initialize(loader, keys)
      @keys   = keys
      @loader = loader
      @config, _ = loader.load(keys)
    end

    def machine_being_read(name, env)
      # Load the configuration for the machine
      results = cupper_config(name, env)
      config          = results[:config]

      # Create the machine and cache it for future calls. This will also
      # return the machine from this method.
      return new_machine(name, config, env) 
    end

    def new_machine(name, config, env)
      machine = Attribute.new
      class << machine
        attr_accessor :name
        attr_accessor :config
        attr_accessor :env
      end
      machine.name = name
      machine.config = config
      machine.env = env
      machine
    end

    def cupper_config(name, env)
      keys = @keys.dup

      config_key = "#{object_id}_machine_being_read_#{name}"
      # Add the configuration to the loader and keys
      keys << config_key

      # Load once so that we can get the proper box value
      config = @loader.load(keys)

      load_proc = lambda do
        local_keys = keys.dup

        # Load the box Cupperfile, if there is one
          
          cupperfile = find_cupperfile(env.root_path)
          if cupperfile
            @loader.set(config_key, cupperfile)
            local_keys.unshift(config_key)
            puts config_key
            puts local_keys
            puts cupperfile
            config = @loader.load(local_keys)
          end
        # TODO: implement a way to change and override recursively here
      end

      # Load the box and provider overrides
      load_proc.call

      return {
        config: config,
        # TODO: add other meaningfull returns
      }
    end

    # @return [Array<Symbol>]
    def names
      @config.defined_keys.dup
    end

    protected

    def find_cupperfile(search_path)
      ["Cupperfile", "cupperfile"].each do |cupperfile|
        current_path = search_path.join(cupperfile)
        return current_path if current_path.file?
      end

      nil
    end

  end
end
