# This module prepare the defaults files and directories that will be needed

module Cupper
  class Config

    def file_content(file_name)
      content = case file_name
      when 'config.yaml' then "# Config file"
      when 'nodes.yaml' then "# Nodes file"
      else "# Invalid!"
      end
      return content
    end

    def initialize
      root = Dir.getwd
      files=[
        'config.yaml',
        'nodes.yaml'
      ]
      dirs=[
        'cookbooks',
        'nodes',
        'roles'
      ]

      files.each do |file|
        if File.exists?(root+file)
          puts "[exists] " + file
        else
          File.open(file, 'w') do |f|
            f.puts file_content(file)
          end
          puts "[create] " + file
        end
      end

      dirs.each do |dir|
        if Dir.exist?(root+dir)
          puts "[exists] " + dir
        else
          Dir.mkdir(dir)
          puts "[create] " + dir
        end
      end
    end

  end
end
