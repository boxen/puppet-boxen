require 'fileutils'

module Puppet::Parser::Functions
  newfunction(:include_projects_from_boxen_cli) do |args|
    Puppet::Parser::Functions.function('include')

    if File.exists?("#{Facter[:boxen_repodir].value}/.projects") \
      && cli_projects = File.read("#{Facter[:boxen_repodir].value}/.projects").strip \
      && FileUtils.rm_rf("#{Facter[:boxen_repodir].value}/.projects")

      cli_projects.split(',').each do |project|
        path = "#{Facter[:boxen_repodir].value}/modules/projects/manifests/#{project}.pp"
        puts path

        if File.exist?(path)
          warning "Setting up '#{project}'. This can be made permanent by having 'include projects::#{project}' in your personal manifest."
          function_include ["projects::#{project}"]
        else
          warning "Don't know anything about '#{project}'. Help out by defining it at '#{path}'."
        end
      end
    end
  end
end
