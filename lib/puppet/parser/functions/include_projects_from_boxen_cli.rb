module Puppet::Parser::Functions
  newfunction(:include_projects_from_boxen_cli) do |args|
    Puppet::Parser::Functions.function('include')

    cli_projects = Facter[:cli_boxen_projects].value

    cli_projects.split(',').each do |project|
      path = "#{Facter[:boxen_repodir].value}/modules/projects/manifests/#{project}.pp"

      if File.exist?(path)
        warning "Setting up '#{project}'. This can be made permanent by having 'include projects::#{project}' in your personal manifest."
        function_include ["projects::#{project}"]
      else
        warning "Don't know anything about '#{project}'. Help out by defining it at '#{path}'."
      end
    end
  end
end
