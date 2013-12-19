#!/usr/bin/env ruby

module Boxen
  module Autocomplete
    # refresh options via: ruby -e 'puts `boxen -h 2>/dev/null`.scan(/\-+[a-z\?-]+/).inspect'
    OPTIONS = ["--debug", "--pretend", "--noop", "--report", "--env", "-h", "-?", "--help", "--disable-service", "--enable-service", "--restart-service", "--disable-services", "--enable-services", "--restart-services", "--list-services", "--homedir", "--logfile", "--login", "--no-fde", "--no-pull", "--no-issue", "--stealth", "--token", "--profile", "--future-parser", "--projects", "--srcdir", "--user", "--no-color"]
    SERVICE_OPTIONS = OPTIONS.select { |o| o.end_with?("-service") }
    DIR_OPTIONS = ["--logfile", "--homedir"]

    class << self
      def complete(typed)
        if part = after(typed, SERVICE_OPTIONS)
          available_services.select { |s| s.start_with?(part) }
        elsif after(typed, DIR_OPTIONS)
          []
        else
          OPTIONS.select { |o| o.start_with?(typed[/([a-z-]*)$/,1].to_s) }
        end
      end

      private

      def after(typed, kind)
        typed[/(#{kind.join("|")})\s+([^\s]*)?$/, 2]
      end

      # keep in sync with boxen/service.rb
      def available_services
        Dir["/Library/LaunchDaemons/dev.*.plist"].map { |f| f[/dev\.(.*)\.plist/, 1] }
      end
    end
  end
end

if $0 == __FILE__
  puts Boxen::Autocomplete.complete(ENV["COMP_LINE"])
end
