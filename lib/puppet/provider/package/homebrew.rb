# The `luser` fact MUST be available, it's used by `sudo` when running
# any `brew` command.

require "pathname"
require "puppet/provider/package"

Puppet::Type.type(:package).provide :homebrew,
  :parent => Puppet::Provider::Package do

  # Brew packages aren't really versionable, but there's a difference
  # between the latest release version and HEAD.

  has_feature :versionable
  has_feature :install_options

  # A list of `ensure` values that aren't explicit versions.

  def self.home
    "#{Facter[:boxen_home].value}/homebrew"
  end

  confine  :operatingsystem => :darwin

  def self.run(*cmds)
    command = ["sudo", "-E", "-u", Facter[:luser].value, "#{home}/bin/brew", *cmds].flatten.join(' ')
    output = `#{command}`
    unless $? == 0
      fail "Failed running #{command}"
    end

    output
  end

  def self.active?(name, version)
    current(name) == version
  end

  def self.available?(name, version)
    version = nil if unversioned? version
    File.exist? File.join [home, "Cellar", simplify(name), version].compact
  end

  def self.current(name)
    link = Pathname.new "#{home}/Library/LinkedKegs/#{simplify name}"
    link.exist? && link.realpath.basename.to_s
  end

  def self.simplify(name)
    name.split("/").last
  end

  # When it comes to Homebrew, none of Puppet's state stuff is to be
  # trusted. Do everything as just-in-time as possible.

  def self.instances
    []
  end

  def self.unversioned?(version)
    %w(present installed absent purged held latest).include? version.to_s
  end

  def install
    version = unversioned? ? latest : resource[:ensure]

    update_formulas if !version_defined?(version) || version == 'latest'

    if self.class.available? resource[:name], version
      # If the desired version is already installed, just link or
      # switch. Somebody might've activated another version for
      # testing or something like that.

      run :switch, resource[:name], version

    elsif self.class.current resource[:name]
      # Okay, so there's a version already active, it's not the right
      # one, and the right one isn't installed. That's an upgrade.

      run "boxen-upgrade", resource[:name]
    else
      # Nothing here? Nothing from before? Yay! It's a normal install.

      run "boxen-install", resource[:name], *install_options
    end
  end

  def update_formulas
    unless self.class.const_defined?(:UPDATED_BREW)
      notice "Updating homebrew formulas"

      run :update rescue nil
      self.class.const_set(:UPDATED_BREW, true)
    end
  end

  def version_defined? version
    defined_versions = `#{self.class.home}/bin/brew info #{resource[:name]}`
    defined_versions = defined_versions.lines.first.strip.split(' ')[2..-1]

    defined_versions.include? version
  end

  def install_options
    Array(resource[:install_options]).flatten.compact
  end

  def latest
    run("boxen-latest", resource[:name]).strip
  end

  def query
    return unless version = self.class.current(resource[:name])
    { :ensure => version, :name => resource[:name] }
  end

  def run(*cmds)
    self.class.run(*cmds)
  end

  def uninstall
    run :uninstall, "--force", self.class.simplify(resource[:name])
  end

  def unversioned?
    self.class.unversioned? resource[:ensure]
  end

  def update
    install
  end

  private
  def lazy_brew(*args)
    brew(*args)
  rescue NoMethodError => e
    if File.exists? "#{self.class.home}/bin/brew"
      self.class.commands :brew => "#{home}/bin/brew"
      brew(*args)
    else
      raise e
    end
  end
end
