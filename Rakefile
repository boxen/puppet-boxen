require 'erb'
require 'octokit'

desc "Update boxen::development repo list from GitHub"
task :update_development do
  repo_count = Octokit.org(:boxen).public_repos
  pages = (repo_count / 30.0).round

  repos = []

  puts "Fetching repos..."
  pages.times do |page|
    puts " * page #{page + 1} of #{pages}"
    Octokit.org_repos(:boxen, :page => (page + 1)).each do |repo|
      repos << repo.name
    end
  end

  puts "Writing manifests/development.pp..."
  tmpl = File.read("./lib/development.pp.erb")
  File.open('./manifests/development.pp', 'w') do |out|
    out.puts ERB.new(tmpl, nil, '-').result(binding)
  end
end
