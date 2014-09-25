# Jeff McCune <mccune.jeff@gmail.com>
# Changed to app.dmg by: Udo Waechter <root@zoide.net>
# Modified to bypass dmg EULAs by Matt Heath <matt@mattheath.com>
# Mac OS X Package Installer which handles application (.app)
# bundles inside an Apple Disk Image.
#
# Motivation: DMG files provide a true HFS file system
# and are easier to manage.
#
# DMG files which require a EULA to be accepted cannot be installed by the
# standard appdmg provider
#
# Note: the 'apple' Provider checks for the package name
# in /L/Receipts.  Since we possibly install multiple apps's from
# a single source, we treat the source .app.dmg file as the package name.
# As a result, we store installed .app.dmg file names
# in /var/db/.puppet_appdmg_installed_<name>

require 'puppet/provider/package'
Puppet::Type.type(:package).provide(:appdmg_eula, :parent => Puppet::Provider::Package) do
  desc "Package management which copies application bundles which require
    acceptance of an EULA to a target."

  confine :operatingsystem => :darwin

  commands :hdiutil => "/usr/bin/hdiutil"
  commands :curl => "/usr/bin/curl"
  commands :ditto => "/usr/bin/ditto"
  commands :chown => "/usr/sbin/chown"

  # JJM We store a cookie for each installed .app.dmg in /var/db
  def self.instances_by_name
    Dir.entries("/var/db").find_all { |f|
      f =~ /^\.puppet_appdmg_installed_/
    }.collect do |f|
      name = f.sub(/^\.puppet_appdmg_installed_/, '')
      yield name if block_given?
      name
    end
  end

  def self.instances
    instances_by_name.collect do |name|
      new(:name => name, :provider => :appdmg, :ensure => :installed)
    end
  end

  def self.installapp(source, name, orig_source)
    appname = File.basename(source);
    target = "/Applications/#{appname}"
    ditto "--rsrc", source, "#{target}"
    chown "-R", "#{Facter[:boxen_user].value}:staff", "#{target}"
    File.open("/var/db/.puppet_appdmg_installed_#{name}", "w") do |t|
      t.print "name: '#{name}'\n"
      t.print "source: '#{orig_source}'\n"
    end
  end

  def self.installpkgdmg(source, name)
    unless source =~ /\.dmg$/i
      self.fail "Mac OS X PKG DMG's must specify a source string ending in .dmg"
    end
    require 'open-uri'
    require 'facter/util/plist'

    Puppet.notice "By installing this software (#{name}), you acknowledge you have read and accepted its End User License Agreement."

    cached_source = source
    tmpdir = Dir.mktmpdir
    begin
      if %r{\A[A-Za-z][A-Za-z0-9+\-\.]*://} =~ cached_source
        cached_source = File.join(tmpdir, name)
        begin
          curl "-o", cached_source, "-C", "-", "-L", "-s", "--url", source
          Puppet.debug "Success: curl transfered [#{name}]"
        rescue Puppet::ExecutionFailure
          Puppet.debug "curl did not transfer [#{name}].  Falling back to slower open-uri transfer methods."
          cached_source = source
        end
      end

      open(cached_source) do |dmg|

        # Mounting a DMG file with a EULA
        #
        # The EULA could be one or more pages, in which case echoing Y into
        # hdiutil doesn't work. Instead This converts the DMG to UDTO format
        # (DVD/CD-R master) then attachs the resultant CDR file - which doesn't
        # have a EULA, as demonstrated in:
        #
        # http://superuser.com/questions/221136/bypass-a-licence-agreement-when-mounting-a-dmg-on-the-command-line#answer-250624

        hdiutil "convert", dmg.path, "-format", "UDTO", "-o", "#{tmpdir}/appdmg_eula"
        xml_str = hdiutil "attach", "-plist", "-nobrowse", "-readonly", "-noverify", "-noautoopen", "-mountrandom", "/tmp", "#{tmpdir}/appdmg_eula.cdr"

        ptable = Plist::parse_xml xml_str
        # JJM Filter out all mount-paths into a single array, discard the rest.
        mounts = ptable['system-entities'].collect { |entity|
          entity['mount-point']
        }.select { |mountloc|; mountloc }
        begin
          mounts.each do |fspath|
            Dir.entries(fspath).select { |f|
              f =~ /\.app$/i
            }.each do |pkg|
              installapp("#{fspath}/#{pkg}", name, source)
            end
          end
        ensure
          hdiutil "eject", mounts[0]
        end
      end
    ensure
      FileUtils.remove_entry_secure(tmpdir)
    end
  end

  def query
    FileTest.exists?("/var/db/.puppet_appdmg_installed_#{@resource[:name]}") ? {:name => @resource[:name], :ensure => :present} : nil
  end

  def install
    source = nil
    unless source = @resource[:source]
      self.fail "Mac OS X PKG DMG's must specify a package source."
    end
    unless name = @resource[:name]
      self.fail "Mac OS X PKG DMG's must specify a package name."
    end
    self.class.installpkgdmg(source,name)
  end
end
