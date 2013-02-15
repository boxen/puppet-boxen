require "boxen/config"

Facter.add("root_encrypted") do
  config = Boxen::Config.load

  def root_encrypted?
    system("/usr/sbin/diskutil coreStorage info / > /dev/null 2>&1")
  end

  setcode do
    ENV['BOXEN_NO_FDE'] || !config.fde? || root_encrypted? ? 'yes' : 'no'
  end
end
