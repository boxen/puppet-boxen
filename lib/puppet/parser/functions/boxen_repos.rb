require 'octokit'

module Puppet::Parser::Functions
  newfunction(:boxen_repos, :type => :rvalue) do |args|
    repos_per_page = 100

    repo_count = Octokit.org(:boxen).public_repos
    pages = (repo_count / repos_per_page.to_f).round
    repos = []

    opts = { :per_page => repos_per_page }

    pages.times do |page|
      opts[:page] = page + 1
      repos.concat Octokit.org_repos(:boxen, opts).map(&:name)
    end

    repos
  end
end
