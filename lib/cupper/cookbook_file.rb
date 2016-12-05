module Cupper
  class CookbookFile
    include Entity
    def initialize(dest_path, source, content, erb_file = nil, type = nil)
      @source   = source
      @content  = content
      super(@source, dest_path, erb_file, type)
    end
  end
end
