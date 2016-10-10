
Ohai.plugin(:InitSystem) do
  provides 'init_system'

  def from_cmd(cmd)
    so = shell_out(cmd)
    so.stdout.strip
  end

  collect_data(:linux) do
    init_system Mash.new
    init_system["init"] = from_cmd("cat /proc/1/comm")
  end
end
