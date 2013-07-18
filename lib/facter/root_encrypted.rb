require "boxen/config"

Facter.add("root_encrypted") do
  config = Boxen::Config.load

  def root_encrypted?
    is_active = `/usr/bin/fdesetup isactive ; echo $?`.chomp
	  is_active == "0" || is_active == "2" ? true : false
  end

  setcode do
    ENV['BOXEN_NO_FDE'] || !config.fde? || root_encrypted? ? 'yes' : 'no'
  end
end
