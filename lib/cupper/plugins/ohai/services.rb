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
      name = srv.split.first
      next unless name.match /\.service/

      # Removing the extention of the service
      name = name.split "."
      name.pop
      name = name.join "."
      services[name] = {
        "action" => 'restart',
        "provider" => 'Chef::Provider::Service::Systemd' # TODO: hard code, needs to collect the provider
      }
    end
  end
end
