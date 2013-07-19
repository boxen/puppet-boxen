require "boxen/config"

Facter.add("root_encrypted") do
  config = Boxen::Config.load

  def root_encrypted?
    system("/usr/bin/fdesetup isactive /")
    [0, 2].include? $?
  end

  setcode do
    ENV['BOXEN_NO_FDE'] || !config.fde? || root_encrypted? ? 'yes' : 'no'
  end
end
