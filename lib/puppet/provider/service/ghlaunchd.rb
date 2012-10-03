Puppet::Type.type(:service).provide :ghlaunchd, :parent => :base do
  commands :launchctl => "/bin/launchctl",
            :plutil   => "/usr/bin/plutil",
            :rm       => "/bin/rm"

  confine :operatingsystem => :darwin

  has_feature :enableable
  mk_resource_methods

  LAUNCHD_DIRS = [
    "/Library/LaunchAgents",
    "/Library/LaunchDaemons",
    "/System/Library/LaunchAgents",
    "/System/Library/LaunchDaemons"
  ]

  def restart
    stop
    start
  end

  def status
    service = launchctl(:list, resource[:name]) rescue nil
    running  = service.include?("PID") rescue nil
    running |= service['OnDemand'] rescue nil
    running ? :running : :stopped
  end

  def enabled?
    if status == :running || File.exist?(plist_file)
      :true
    else
      :false
    end
  end

  def start
    return false if plist_file.to_s.empty?
    launchctl :load, "-w", plist_file
    if config['inetdCompatibility'].nil?
      launchctl :start, resource[:name]
    end
  rescue => e
    if e.message =~ /Can't find #{name}/
      false
    else
      raise e
    end
  end

  def stop
    return false if plist_file.to_s.empty?
    launchctl :unload, "-w", plist_file
  rescue => e
    if e.message =~ /Can't find #{name}/
      true
    else
      raise e
    end
  end

  def enable
    start
  end

  def disable
    return true if plist_file.to_s.empty?
    stop
    rm(plist_file) if File.exist?(plist_file) && ! plist_file.to_s.empty?
    true
  end

  # The merged configuration for this service, including data from the
  # service's plist file and launchd's overrides database.

  def config
    plist.merge overrides
  end

  # A Hash of configuration information for this service, pulled from
  # launchd's overrides database. Normally you'll want to use `config`
  # instead of using `overrides` directly.

  def overrides
    file = "/var/db/launchd.db/com.apple.launchd/overrides.plist"
    json = plutil "-convert", "json", "-o", "/dev/stdout", file
    data = JSON.parse json

    data[resource[:name]] || {}
  end

  # A Hash of configuration information parsed from `plist_file`.
  # Normally you'll want to use `config` instead of using `plist`
  # directly.

  def plist
    JSON.parse plutil("-convert", "json", "-o", "/dev/stdout", plist_file)
  end

  # The launchd `.plist` file for this service, which must exist in
  # one of the `LAUNCHD_DIRS`. Raises if the file can't be found.

  def plist_file
    return @plist_file if defined? @plist_file

    name = "#{resource[:name]}.plist"
    glob = "{" + LAUNCHD_DIRS.join(",") + "}/#{name}"

    @plist_file = Dir[glob].first.to_s or raise "Can't find #{name}."
  end
end
