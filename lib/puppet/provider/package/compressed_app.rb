require "open-uri"
require "puppet/provider/package"

Puppet::Type.type(:package).provide :compressed_app,
:parent => Puppet::Provider::Package do
  desc "Installs a compressed .app. Supports zip, tar.gz, tar.bz2"

  SOURCE_TYPES = %w(zip tar.gz tar.bz2 tgz tbz)

  confine  :operatingsystem => :darwin

  commands :ditto => "/usr/bin/ditto"

  def self.instances_by_name
    Dir.entries("/var/db").find_all { |f|
      f =~ /^\.puppet_compressed_app_installed_/
    }.collect do |f|
      name = f.sub(/^\.puppet_compressed_app_installed_/, '')
      yield name if block_given?
      name
    end
  end

  def self.instances
    instances_by_name.collect do |name|
      new(:name => name, :provider => :compressed_app, :ensure => :installed)
    end
  end

  def self.install_compressed_app(name, source, flavor = nil)
    FileUtils.mkdir_p '/opt/boxen/cache'
    source_type = case
                  when flavor
                    flavor
                  when source =~ /\.zip$/i
                    'zip'
                  when source =~ /\.tar\.gz$/i
                    'tar.gz'
                  when source =~ /\.tgz$/i
                    'tgz'
                  when source =~ /\.tar\.bz2$/i
                    'tar.bz2'
                  when source =~ /\.tbz$/i
                    'tbz'
                  else
                    self.fail "Source must be one of .zip, .tar.gz, .tgz, .tar.bz2, .tbz"
                  end


    execute "curl '#{source}' -L -q -o '/opt/boxen/cache/#{name}.app.#{source_type}'"
    execute "rm -rf '/Applications/#{name}.app'", :uid => 'root'

    case source_type
    when 'zip'
      ditto "-xk", cached_source, "/Applications", :uid => 'root'
    when 'tar.gz', 'tgz'
      execute [
        "/usr/bin/tar",
        "-zxf",
        "'/opt/boxen/cache/#{name}.app.#{source_type}'",
        "-C",
        "/Applications"
      ].join(' '), :uid => 'root'
    when 'tar.bz2', 'tbz'
      execute [
        "/usr/bin/tar",
        "-jxf",
        "'/opt/boxen/cache/#{name}.app.#{source_type}'",
        "-C",
        "/Applications"
      ].join(' '), :uid => 'root'
    end

    execute [
      "/usr/sbin/chown",
      "-R",
      "#{Facter[:boxen_user].value}:admin",
      "/Applications/#{name}.app"
    ].join(" "), :uid => 'root'

    File.open("/var/db/.puppet_compressed_app_installed_#{name}", "w") do |t|
      t.print "name: '#{name}'\n"
      t.print "source: '#{source}'\n"
    end
  end

  def self.uninstall_compressed_app(name)
    execute "rm -rf '/Applications/#{name}'", :uid => 'root'
    execute "rm -f '/var/db/.puppet_compressed_app_installed_#{name}'"
  end

  def query
    if File.exists?("/var/db/.puppet_compressed_app_installed_#{@resource[:name]}")
      {
        :name   => @resource[:name],
        :ensure => :installed
      }
    end
  end

  def install
    unless source = @resource[:source]
      self.fail "OS X compressed apps must specify a package source"
    end

    unless name = @resource[:name]
      self.fail "OS X compressed apps must specify a package name"
    end

    if flavor = @resource[:flavor]
      unless SOURCE_TYPES.member? flavor
        self.fail "Unsupported flavor"
      end
    end

    self.class.install_compressed_app name, source, flavor
  end

  def uninstall
    self.class.uninstall_compressed_app @resource[:name]
  end
end
