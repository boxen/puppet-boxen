require "json"
require "boxen/config"

config   = Boxen::Config.load
facts    = {}
factsdir = File.join config.homedir, "config", "facts"

facts["github_login"]   = config.login
facts["github_email"]   = config.email
facts["github_name"]    = config.name

facts["boxen_home"]     = config.homedir
facts["boxen_srcdir"]   = config.srcdir

if config.respond_to? :reponame
  facts["boxen_reponame"] = config.reponame
end

facts["luser"]          = config.user

if config.respond_to? :repotemplate
  facts["boxen_repo_url_template"] = config.repotemplate
else
  facts["boxen_repo_url_template"] = "https://github.com/%s"
end

Dir["#{config.homedir}/config/facts/*.json"].each do |file|
  facts.merge! JSON.parse File.read file
end

facts.each { |k, v| Facter.add(k) { setcode { v } } }
