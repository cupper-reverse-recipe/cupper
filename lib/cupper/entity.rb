module Cupper
  # Entity can be a directory or file
  class Entity
    FILE = 'file'
    DIR = 'dir'

    # Contructor
    def initialize(type)
      @destination_path = ''
      @file_or_dir = type
    end

    # Create the actual file or dir in the correct place
    def create
    end

    # Returns the content of the file
    def content
      return false if self.file?
    end

    # Returns the template of the file
    def template
    end

    # There is a difference between file or directory
    def file?
      @file_or_dir == FILE
    end
    def dir?
      @file_or_dir == DIR
    end
  end
end
