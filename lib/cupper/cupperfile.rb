module Cupper
  class Cupperfile

    def initialize(key)
      @key   = key
      @config, _ = Cupper::Config.load(key)
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
      cupperfile = env.find_cupperfile(env.root_path)
      if cupperfile
        config = Cupper::Config.load(cupperfile)
      end

      return {
        config: config,
        # TODO: add other meaningfull returns
      }
    end
  end
end
