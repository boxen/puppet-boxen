require "open-uri"
require "puppet/provider/package"

Puppet::Type.type(:package).provide :compressed_pkg,
:parent => Puppet::Provider::Package do
  desc "Installs a compressed .pkg or .mpkg. Supports zip, tar.gz, tar.bz2"

  PKG_SOURCE_TYPES = %w(zip tar.gz tar.bz2 tgz tbz)

  commands :installer => "/usr/sbin/installer"
  confine  :operatingsystem => :darwin

  def self.instances_by_name
    Dir.entries("/var/db").find_all { |f|
      f =~ /^\.puppet_compressed_pkg_installed_/
    }.collect do |f|
      name = f.sub(/^\.puppet_compressed_pkg_installed_/, '')
      yield name if block_given?
      name
    end
  end

  def self.instances
    instances_by_name.collect do |name|
      new(:name => name, :provider => :compressed_pkg, :ensure => :installed)
    end
  end

  def self.installpkg(source, name, orig_source)
    installer "-pkg", source, "-target", "/"
    # Non-zero exit status will throw an exception.
    File.open("/var/db/.puppet_compressed_pkg_installed_#{name}", "w") do |t|
      t.print "name: '#{name}'\n"
      t.print "source: '#{orig_source}'\n"
    end
  end

  def self.install_compressed_pkg(name, source, flavor = nil)
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


    execute "curl '#{source}' -L -q -o '/opt/boxen/cache/#{name}.pkg.#{source_type}'"

    tmpdir = "/opt/boxen/cache/#{name}"
    case source_type
    when 'zip'
      execute [
        "/usr/bin/unzip",
        "-o",
        "'/opt/boxen/cache/#{name}.pkg.#{source_type}'",
        "-d",
        tmpdir
      ].join(' '), :uid => 'root'
    when 'tar.gz', 'tgz'
      execute [
        "/usr/bin/tar",
        "-zxf",
        "'/opt/boxen/cache/#{name}.pkg.#{source_type}'",
        "-C",
        tmpdir
      ].join(' '), :uid => 'root'
    when 'tar.bz2', 'tbz'
      execute [
        "/usr/bin/tar",
        "-jxf",
        "'/opt/boxen/cache/#{name}.pkg.#{source_type}'",
        "-C",
        tmpdir
      ].join(' '), :uid => 'root'
    end

    Dir.entries(tmpdir).select { |f|
      f =~ /\.m{0,1}pkg$/i
    }.each do |pkg|
      installpkg("#{tmpdir}/#{pkg}", name, source)
    end
  end

  def query
    if File.exists?("/var/db/.puppet_compressed_pkg_installed_#{@resource[:name]}")
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
      unless PKG_SOURCE_TYPES.member? flavor
        self.fail "Unsupported flavor"
      end
    end

    self.class.install_compressed_pkg name, source, flavor
  end

end
