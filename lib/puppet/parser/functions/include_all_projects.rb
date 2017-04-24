module Puppet::Parser::Functions
  newfunction(:include_all_projects) do |args|
    Puppet::Parser::Functions.function('include')

    repo = "#{Facter[:boxen_home].value}/repo"
    prefix = "#{repo}/modules/projects/manifests"
    Dir["#{prefix}/**/*.pp"].each do |path|
      project = path.gsub /^#{prefix}\/|\.pp$/, ''
      class_name = project.gsub /\//, '::'

      next if class_name == 'all'

      function_include [class_name]
    end
  end
end
