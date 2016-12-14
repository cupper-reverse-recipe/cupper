require "pathname"

module Cupper
  module Config
    # This class is responsible for loading Cupper configuration,
    # usually in the form of Cupperfiles.
    #
    # Loading works by specifying the sources for the configuration
    # as well as the order the sources should be loaded. Configuration
    # set later always overrides those set earlier; this is how
    # configuration "scoping" is implemented.
    class Loader
      def initialize()
        @config_cache  = {}
        @proc_cache    = {}
        @sources       = {}
      end
      # Set the configuration data for the given name.
      #
      # The `name` should be a symbol and must uniquely identify the data
      # being given.
      #
      # `data` can either be a path to a Ruby Vagrantfile or a `Proc` directly.
      # `data` can also be an array of such values.
      #
      # At this point, no configuration is actually loaded. Note that calling
      # `set` multiple times with the same name will override any previously
      # set values. In this way, the last set data for a given name wins.
      def set(name, sources)
        # Sources should be an array
        sources = [sources] if !sources.kind_of?(Array)

        reliably_inspected_sources = sources.reduce({}) { |accum, source|
          begin
            accum[source] = source.inspect
          rescue Encoding::CompatibilityError
            accum[source] = "<!Cupper failed to call #inspect source with object id #{source.object_id} and class #{source.class} due to a string encoding error>"
          end

          accum
        }

        # Gather the procs for every source, since that is what we care about.
        procs = []
        sources.each do |source|
          if !@proc_cache.key?(source)
            # Load the procs for this source and cache them. This caching
            # avoids the issue where a file may have side effects when loading
            # and loading it multiple times causes unexpected behavior.
            @proc_cache[source] = procs_for_source(source, reliably_inspected_sources)
          end

          # Add on to the array of procs we're going to use
          procs.concat(@proc_cache[source])
        end

        # Set this source by name.
        @sources[name] = procs
      end

      def load(order)

        order.each do |key|
          next if !@sources.key?(key)

          @sources[key].each do | proc|
            if !@config_cache.key?(proc)

              config = loader.load(proc)

              @config_cache[proc] = [config]
            else
              puts "Loading from: #{key} (cache)"
            end

            # Merge the configurations
            cache_data = @config_cache[proc]
            result = result.merge(result, cache_data[0])
          end
        end

        puts "Configuration loaded successfully, finalizing and returning"
        [result.finalize(result)]
      end

    end
  end
end
