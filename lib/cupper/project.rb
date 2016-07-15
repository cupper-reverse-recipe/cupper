# This module prepare the Cupper project with the
#   defaults files and dirs. All the files created are
#   just samples and must to be changed by the user

module Cupper
  class Project
    attr_reader :name
    attr_reader :dir
    attr_reader :subdirs
    attr_reader :files

    def initialize(name)
      @name = name
      @dir = "#{Dir.getwd}/#{name}"
      @subdirs = [
        'cookbooks',
      ]
      @files = [
        'CupperFile',
      ]
    end

    def create()
      if Dir.exist?(@dir)
        puts 'Fail: Project already exists or there is a directory with the same name'
      else
        create_dir
        create_subdir
        create_files
      end
    end

    private

    def create_dir
      Dir.mkdir(@dir)
      puts "[created] " + @name
    end

    def create_subdir
      @subdirs.each do |subdir|
        path = "#{@dir}/#{subdir}"
        if Dir.exist?(path)
          puts "[exists] " + subdir
        else
          Dir.mkdir(path)
          puts "[created] " + subdir
        end
      end
    end

    def create_files
      @files.each do |file|
        path = "#{@dir}/#{file}"
        if File.exists?(path)
          puts "[exists] " + file
        else
          File.open(path, 'w') do |f|
            f.puts file_content(file)
          end
          puts "[created] " + file
        end
      end
    end

    def file_content(file)
      content = case file
      when 'Cupperfile' then "# Cupper config file"
      else "# Invalid!"
      end
      return content
    end
  end
end
