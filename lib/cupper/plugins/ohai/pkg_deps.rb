Ohai.plugin(:PkgDeps) do
  provides 'pkg_deps'
  depends 'platform_family'

  def from_cmd(cmd)
    so = shell_out(cmd)
    so.stdout.lines
  end

  def all_packages
    if %w{debian}.include? platform_family
      from_cmd("dpkg-query -W")
    end
  end

  def extract_dependecies(pkg)
    pkg_infos = from_cmd("apt-cache showpkg #{pkg}")
    pkg_infos.keep_if { |item| item.strip!.match(/^Depends:/)}
    pkg_infos.each { |item| item.slice!("Depends: ") }
  end

  collect_data(:linux) do
    pkg_deps Mash.new
    if %w{debian}.include? platform_family
      all_packages.each do |pkg|
        pkg_deps[pkg.split.first] = extract_dependecies(pkg.split.first)
      end
    end
  end
end
