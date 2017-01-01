Ohai.plugin(:PkgRepository) do
  depends 'packages'

  def from_cmd(cmd)
    so = shell_out(cmd)
    so.stdout.lines
  end

  # Converte the array with the version
  def version_table(versions)
    table = Hash.new
    versions.each do |line|
      if line.include? "500" or line.include? "100"
        table[line.first] = {}
      end
    end
  end

  collect_data(:linux) do
    packages.each do |pkg|
      repo = from_cmd("apt-cache policy #{pkg.first}")

      installed = repo[1].strip.split[1]
      canditate = repo[2].strip.split[1]

      table = version_table(repo.drop 4)

      package[pkg].merge(table)
    end
  end
end
