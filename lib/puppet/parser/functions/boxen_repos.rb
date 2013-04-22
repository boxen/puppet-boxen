require 'octokit'

module Puppet::Parser::Functions
  newfunction(:boxen_repos, :type => :rvalue) do |args|
    repo_count = Octokit.org(:boxen).public_repos
    pages = (repo_count / 30.0).round
    repos = []

    pages.times do |page|
      Octokit.org_repos(:boxen, :page => (page + 1)).each do |repo|
        repos << repo.name
      end
    end

    return repos
  end
end
