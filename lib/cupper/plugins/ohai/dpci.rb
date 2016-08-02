
Ohai.plugin(:Pci) do
  provides 'dpci'

  def from_cmd(cmd)
    so = shell_out(cmd)
    so.stdout.lines
  end

  collect_data(:default) do
    dpci Mash.new
    pcis from_cmd('lspci')

    r_bus_slot_num = /\d+:[0-9a-fA-F]+\.\d\s/
    r_slot_name = /^[A-z\s]+/

    pcis.each_with_index do |pci, i|
      bus_slot_num = pci.slice! r_bus_slot_num
      slot_name = pci.slice! r_slot_name
      pci.slice! /^:\s/
      device_name = pci

      dpci["pci_#{i}"] = {
        "bus_slot_num" =>  bus_slot_num,
        "slot_name" => slot_name,
        "device_name" => device_name
      }
    end
  end
end
