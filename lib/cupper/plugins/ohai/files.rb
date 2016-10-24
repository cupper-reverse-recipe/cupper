Ohai.plugin(:Files) do
  provides 'files'

  def from_cmd(cmd)
    so = shell_out(cmd)
    so.stdout.lines
  end

  def has_related_package?(file)
    related = shell_out("dpkg -S #{file}")
    !(related.match('no path found matching pattern'))
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
      if has_related_package?(file)
        path, type = file.split(' ', 2)
        path.chomp!(':')
        mode, null, owner, group, null = shell_out("ls -al #{path}").stdout.split(' ',5)
        content = shell_out("cat #{path}")
        files[path] = {
          'type' => type,
          'mode' => mode,
          'owner' => owner,
          'group' => group,
          'content' => content
        }
      end
    end
  end
end
