require "open-uri"
require "puppet/provider/package"

Puppet::Type.type(:package).provide :compressed_app,
:parent => Puppet::Provider::Package do
  desc "Installs a compressed .app. Supports zip, tar.gz, tar.bz2"

  SOURCE_TYPES = %w(zip tgz tar.gz tbz tbz2 tar.bz2)

  confine  :operatingsystem => :darwin

  commands :curl  => "/usr/bin/curl"
  commands :ditto => "/usr/bin/ditto"
  commands :tar   => "/usr/bin/tar"
  commands :chown => "/usr/sbin/chown"
  commands :rm    => "/bin/rm"

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

  def query
    if File.exists?(receipt_path)
      {
        :name   => @resource[:name],
        :ensure => :installed
      }
    end
  end

  def install
    unless @resource[:source]
      self.fail "OS X compressed apps must specify a package source"
    end

    unless SOURCE_TYPES.member? @resource[:flavor]
      self.fail "Unsupported flavor"
    end

    unless @resource[:name]
      self.fail "OS X compressed apps must specify a package name"
    end

    FileUtils.mkdir_p '/opt/boxen/cache'
    curl @resource[:source], "-Lqo", cached_path
    rm "-rf", app_path, :uid => 'root'

    case source_type
    when 'zip'
      ditto "-xk", cached_path, "/Applications", :uid => 'root'
    when 'tar.gz', 'tgz'
      tar "-zxf", cached_path, "-C", "/Applications", :uid => 'root'
    when 'tar.bz2', 'tbz', 'tbz2'
      tar "-jxf", cached_path, "-C", "/Applications", :uid => 'root'
    end

    chown "-R", "#{Facter[:boxen_user].value}:admin", app_path, :uid => 'root'

    File.open(receipt_path, "w") do |t|
      t.print "name: '#{@resource[:name]}'\n"
      t.print "source: '#{source}'\n"
    end
  end

  def uninstall
    rm "-rf", app_path, :uid => 'root'
    rm "-f", receipt_path
  end

private

  def source_type
    @resource[:flavor] ||
      @resource[:source].match(/\.(#{SOURCE_TYPES.join('|')})$/i){|m| m[0] } ||
      self.fail("Source must be .zip, .tar.gz, .tgz, .tar.bz2, or .tbz")
  end

  def app_path
    "/Applications/#{@resource[:name]}.app"
  end

  def cached_path
    "/opt/boxen/cache/#{@resource[:name]}.app.#{source_type}"
  end

  def receipt_path
    "/var/db/.puppet_compressed_app_installed_#{@resource[:name]}"
  end

end
