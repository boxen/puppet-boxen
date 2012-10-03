Facter.add("root_encrypted") do
  setcode do
    ENV["BOXEN_NO_FDE"] || system("/usr/sbin/diskutil coreStorage info / > /dev/null 2>&1")
  end
end
