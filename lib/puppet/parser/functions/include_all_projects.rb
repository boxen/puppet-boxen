module Puppet::Parser::Functions
  newfunction(:include_all_projects) do |args|
    Puppet::Parser::Functions.function('include')

    repo = "#{Facter[:boxen_home].value}/repo"
    Dir["#{repo}/modules/projects/manifests/*.pp"].each do |project|
      class_name = project.split('/').last

      next if class_name =~ /all\.pp$/

      function_include [class_name.gsub(/\.pp$/, '')]
    end
  end
end