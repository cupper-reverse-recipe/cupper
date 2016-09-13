Ohai.plugin(:Files) do
  provides 'files'

  def from_cmd(cmd)
    so = shell_out(cmd)
    so.stdout.lines
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
      mode, null, owner, group, null = shell_out('ls -al ' + path.chomp(':')).stdout.split(' ',5)
      files[path.chomp(':')] = {
        'type' => type,
        'mode' => converte_mode(mode),
        'owner' => owner,
        'group' => group
      }
    end
  end
end
