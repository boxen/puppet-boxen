require "open-uri"
require "puppet/provider/package"

Puppet::Type.type(:package).provide :compressed_app,
:parent => Puppet::Provider::Package do
  desc "Installs a compressed .app. Supports zip, tar.gz, tar.bz2"

  FLAVORS = %w(zip tgz tar.gz tbz tbz2 tar.bz2)

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
    fail("OS X compressed apps must specify a package name") unless @resource[:name]
    fail("OS X compressed apps must specify a package source") unless @resource[:source]
    fail("Unknown flavor #{flavor}") unless FLAVORS.include?(flavor)

    FileUtils.mkdir_p '/opt/boxen/cache'
    curl @resource[:source], "-Lqo", cached_path
    rm "-rf", app_path

    case flavor
    when 'zip'
      ditto "-xk", cached_path, "/Applications"
    when 'tar.gz', 'tgz'
      tar "-zxf", cached_path, "-C", "/Applications"
    when 'tar.bz2', 'tbz', 'tbz2'
      tar "-jxf", cached_path, "-C", "/Applications"
    else
      fail "Can't decompress flavor #{flavor}"
    end

    chown "-R", "#{Facter[:boxen_user].value}:staff", app_path

    File.open(receipt_path, "w") do |t|
      t.print "name: '#{@resource[:name]}'\n"
      t.print "source: '#{@resource[:source]}'\n"
    end
  end

  def uninstall
    rm "-rf", app_path
    rm "-f", receipt_path
  end

private

  def flavor
    @resource[:flavor] || @resource[:source].match(/\.(#{FLAVORS.join('|')})$/i){|m| m[1] }
  end

  def app_path
    "/Applications/#{@resource[:name]}.app"
  end

  def cached_path
    "/opt/boxen/cache/#{@resource[:name]}.app.#{flavor}"
  end

  def receipt_path
    "/var/db/.puppet_compressed_app_installed_#{@resource[:name]}"
  end

end
