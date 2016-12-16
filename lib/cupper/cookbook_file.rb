module Cupper
  class CookbookFile
    include Entity

    def initialize(dest_path, source, content, erb_file, full_path, type = nil)
      @source    = source
      @content   = content
      puts content if full_path.include? "sources.list"
      @file_path = dest_path
      subdir = full_path.split('/')
      subdir.pop
      @subdir_path = subdir.join('/')
      self.setup_path
      super(@source, @file_path+@subdir_path, erb_file, type)
    end

    def setup_path
      require 'fileutils'
      FileUtils.mkdir_p @file_path+@subdir_path
    end
  end
end
