Facter.add("root_encrypted") do
  confine :osfamily => 'Darwin'

  def root_encrypted?
    system("/usr/bin/fdesetup isactive / >/dev/null")
    [0, 2].include? $?.exitstatus
  end

  setcode do
    require "boxen/config"
    config = Boxen::Config.load

    ENV['BOXEN_NO_FDE'] || !config.fde? || root_encrypted? ? 'yes' : 'no'
  end
end
