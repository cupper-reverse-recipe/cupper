
Ohai.plugin(:Pacman) do
  provides 'pacman'

  def from_cmd(cmd)
    so = shell_out(cmd)
    so.stdout.lines
  end

  def extract_dependencies(pkg)
    pkg_infos = from_cmd("pacman -Qi #{pkg}")
    infos = pkg_infos.stdout.lines
    infos.each do |info|
      info.slice! /Depends On\s+:/ if info.include? "Depends On"
    end
    info
  end

  collect_data(:default) do
    pacman Mash.new
    pkgs from_cmd('pacman -Q')

    pkgs.each do |pkg|
      name, version = pkg.split
      pacman[name] = {
        "version" => version,
        "dependecies" => info,
      }
    end
  end
end
