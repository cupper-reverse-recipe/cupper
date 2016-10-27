Ohai.plugin(:Files) do
  provides 'files'

  def from_cmd(cmd)
    so = shell_out(cmd)
    so.stdout.lines
  end

  def has_related_package?(file)
    related = shell_out("dpkg -S #{file}").stdout.chomp
    !(related.empty?)
  end

  def related_to(file)
    pkg, null = shell_out("dpkg -S #{file}").stdout.chomp.split(' ', 2)
    pkg.chomp!(':')
  end

  def file_content(file)
    shell_out("cat #{file}").stdout
  end

  def add_info(file)
    shell_out("ls -al #{file}").stdout.split(' ',5)
  end

  def extract_files
    subdir = true
    cmd = 'file /etc/**'
    result = Array.new
    while subdir do
      result << from_cmd(cmd)
      cmd += '/**'
      result.flatten!
      subdir = false if result.last.match('cannot open')
    end
    result
  end

  collect_data(:linux) do
    files Mash.new
    extract_files.each do |file|
      path, type = file.split(' ', 2)
      type.chomp!
      path.chomp!(':')
      mode, null, owner, group, null = add_info(path)
      rel = related_to(path) if has_related_package?(path)
      content = file_content(path)
      files[path] = {
        'type' => type,
        'mode' => mode,
        'owner' => owner,
        'group' => group,
        'related' => rel,
        'content' => content
      }
    end
  end
end
