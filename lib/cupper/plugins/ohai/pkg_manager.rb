
Ohai.plugin(:PkgManager) do
  provides 'pkg_manager'

  def return_version(cmd)
    out = shell_out("#{cmd} || true")
    value out.stdout.strip
    value.match(/(\d+\.)(\d+\.)(\d+)/)
  end

  collect_data(:linux) do
    pkg_manager Mash.new

    # HACK: it may be a better way to collect the default pkg manages
    DEFAULT_PKG_MANAGES = [
      'pacman',
      'dpkg',
      'apt',
      'gem',
      'pip',
      'pip3',
    ]

    DEFAULT_PKG_MANAGES.each do |manager|
      pkg_manager[manager] = {
        "version" => return_version("#{manager} --version")
      }
    end

  end
end
