require "json"
require "boxen/config"

config      = Boxen::Config.load
facts       = {}
dot_boxen   = "#{ENV['HOME']}/.boxen"
user_config = "#{dot_boxen}/config.json"

facts["github_login"]  = config.login
facts["github_email"]  = config.email
facts["github_name"]   = config.name
facts["github_token"]  = config.token

facts["boxen_home"]     = config.homedir
facts["boxen_srcdir"]   = config.srcdir
facts["boxen_repodir"]  = config.repodir
facts["boxen_reponame"] = config.reponame
facts["boxen_user"]     = config.user
facts["luser"]          = config.user # this is goin' away

Dir["#{config.homedir}/config/facts/*.json"].each do |file|
  facts.merge! JSON.parse File.read file
end

if File.directory?(dot_boxen) && File.file?(user_config)
  facts.merge! JSON.parse(File.read(user_config))
end

if File.file?(dot_boxen)
  warn "DEPRECATION: ~/.boxen is deprecated and will be removed in 2.0; use ~/.boxen/config.json instead!"
  facts.merge! JSON.parse(File.read(dot_boxen))
end

if config.respond_to? :repotemplate
  facts["boxen_repo_url_template"] = config.repotemplate
else
  facts["boxen_repo_url_template"] = "https://github.com/%s"
end

if config.respond_to? :s3host
  facts["boxen_s3_host"] = config.s3host
else
  facts["boxen_s3_host"] = "s3.amazonaws.com"
end

if config.respond_to? :s3bucket
  facts["boxen_s3_bucket"] = config.s3bucket
else
  facts["boxen_s3_bucket"] = "boxen-downloads"
end

facts.each do |k, v|
  unless Facter.value(k)
    Facter.add(k) { setcode { v } }
  end
end
