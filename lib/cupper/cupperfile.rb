module Cupper
  class Cupperfile

    def initialize(loader, keys)
      @keys   = keys
      @loader = loader
      @config, _ = loader.load(keys)
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
