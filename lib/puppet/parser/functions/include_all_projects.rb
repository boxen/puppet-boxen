module Puppet::Parser::Functions
  newfunction(:include_all_projects) do |args|
    Puppet::Parser::Functions.function('include')

    repo = "#{Facter[:boxen_home].value}/repo"
    Dir["#{repo}/modules/projects/manifests/*.pp"].each do |project|
      next if project =~ /all\.pp$/

      function_include [project.gsub(/\.pp$/, '')]
    end
  end
end