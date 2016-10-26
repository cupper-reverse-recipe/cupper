Ohai.plugin(:Services) do
  provides 'services'

  def from_cmd(cmd)
    so = shell_out(cmd)
    so.stdout.lines
  end

  collect_data(:default) do
    services Mash.new
    srvs from_cmd('systemctl list-units | grep loaded | grep active | grep running')

    srvs.each do |srv|
      name = from_cmd("echo '#{srv}' | cut -d' ' -f 3")
      puts name*80
      services[name] = {
        "action" => 'restart',
      }
    end
  end
end
