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
    launchctl :start, resource[:name]
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

  # The launchd `.plist` file for this service, which must exist in
  # one of the `LAUNCHD_DIRS`. Raises if the file can't be found.

  def plist_file
    return @plist_file if defined? @plist_file

    name = "#{resource[:name]}.plist"
    glob = "{" + LAUNCHD_DIRS.join(",") + "}/#{name}"

    @plist_file = Dir[glob].first.to_s or raise "Can't find #{name}."
  end
end
