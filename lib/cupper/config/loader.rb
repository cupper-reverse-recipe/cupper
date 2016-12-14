require "pathname"
require "cupper/errors"
require 'colorize'


module Cupper
  module Config

    CONFIGURE_MUTEX = Mutex.new

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
      # `data` can either be a path to a Ruby Cupperfile or a `Proc` directly.
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

      def procs_for_source(source, reliably_inspected_sources)
        # Convert all pathnames to strings so we just have their path
        source = source.to_s if source.is_a?(Pathname)

        if source.is_a?(Array)
          # An array must be formatted as [version, proc], so verify
          # that and then return it
          raise ArgumentError, "String source must have format [version, proc]" if source.length != 2

          # Return it as an array since we're expected to return an array
          # of [version, proc] pairs, but an array source only has one.
          return [source]
        elsif source.is_a?(String)
          # Strings are considered paths, so load them
          return procs_for_path(source)
        else
          raise ArgumentError, "Unknown configuration source: #{reliably_inspected_sources[source]}"
        end
      end

      def procs_for_path(path)
        puts "Load procs for pathname: #{path}"

        return capture_configures do
          begin
            Kernel.load path
          rescue SyntaxError => e
            # Report syntax errors in a nice way.
            raise Errors::CupperfileSyntaxError, file: e.message

          rescue SystemExit => ex
            # Continue raising that exception...
            puts "#{ex.message}".red
          rescue Cupper::Errors::CupperError => ex
            # Continue raising known Vagrant errors since they already
            # contain well worded error messages and context.
            puts "#{ex.message}".red
          rescue Exception => e
            puts "Cupperfile load error: #{e.message}".red
            puts e.backtrace.join("\n").red

            line = "(unknown)"
            if e.backtrace && e.backtrace[0]
              e.backtrace[0].split(":").each do |part|
                if part =~ /\d+/
                  line = part.to_i
                  break
                end
              end
            end

            # Report the generic exception
            raise Errors::CupperfileLoadError,
              path: path,
              line: line,
              exception_class: e.class,
              message: e.message.red
          end
        end
      end

      def capture_configures
        CONFIGURE_MUTEX.synchronize do
          # Reset the last procs so that we start fresh
          @last_procs = []

          # Yield to allow the caller to do whatever loading needed
          yield

          # Return the last procs we've seen while still in the mutex,
          # knowing we're safe.
          return @last_procs
        end
      end

    end
  end
end
